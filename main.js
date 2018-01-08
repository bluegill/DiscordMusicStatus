'use strict'
/**
current issues:
  macOS support only
  streaming from apple music doesn't work, the song must be saved
  reliability problems, song doesn't change sometimes

these issues will be (hopefully) be fixed in the future
**/

const Discord = require('discord.js')
const { spawn } = require('child_process')

const config = require('./config')

class MusicStatus {
  constructor(token) {
    this.client = new Discord.Client()

    // account token is found in discord's local storage after you are logged in
    token = ((!token) ? config.account_token : token)

    this.client.login(token)

    this.client.on('ready', () => {
      this.client.user.setAFK(true)

      // checks for new song every 20s by default
      // anything below ~10s could cause rate limiting issues
      this.createInterval(config.check_interval)
    })
  }

  setPresence(currentSong) {
    if (Object.keys(currentSong).length) {
      if (currentSong.artist === '') {
        return (
          this.client.user.setPresence({ status: config.account_status, game: { name: `${currentSong.title}` } })
        )
      } else {
        return (
          this.client.user.setPresence({ status: config.account_status, game: { name: `${currentSong.title} by ${currentSong.artist}` } })
        )
      }
    }

    this.client.user.setPresence({ status: config.account_status, game: { name: '' } })
  }

  getPlaying(callback) {
    const path = `${__dirname}/bin/getSong.scpt`
    const command = spawn('osascript', [path])

    command.stdout.on('data', (data) => {
      data = data.toString().trim()

      let currentSong = {}

      if (data !== 'none') {
        currentSong.title = data.split('title:')[1].split(', artist:')[0]
        currentSong.artist = data.split('artist:')[1].split('\n')[0]
        currentSong.application = data.split('application:')[1].split(', title:')[0]

        if (currentSong && (currentSong.application === 'soundcloud')) {
          // remove junk some browsers add before the song title
          if (currentSong.title.charAt(0) === '▶') {
            currentSong.title = currentSong.title.substr(2)
          }
        }
      }

      callback(currentSong)
    })
  }

  createInterval(interval) {
    setInterval(() => {
      this.getPlaying((currentSong) => {
        this.setPresence(currentSong)
      })
    }, interval)
  }
}

module.exports = new MusicStatus