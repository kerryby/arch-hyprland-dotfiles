.pragma library

function rgba(hex, alpha) {
  if (!hex || hex.length < 7) return "rgba(0,0,0,0)"
  var r = parseInt(hex.slice(1, 3), 16)
  var g = parseInt(hex.slice(3, 5), 16)
  var b = parseInt(hex.slice(5, 7), 16)
  return "rgba(" + r + "," + g + "," + b + "," + alpha + ")"
}

function darken(hex, percent) {
  var r = parseInt(hex.slice(1, 3), 16)
  var g = parseInt(hex.slice(3, 5), 16)
  var b = parseInt(hex.slice(5, 7), 16)
  r = Math.floor(r * (1 - percent))
  g = Math.floor(g * (1 - percent))
  b = Math.floor(b * (1 - percent))
  return "#" + r.toString(16).padStart(2,"0") + g.toString(16).padStart(2,"0") + b.toString(16).padStart(2,"0")
}

function lighten(hex, percent) {
  var r = parseInt(hex.slice(1, 3), 16)
  var g = parseInt(hex.slice(3, 5), 16)
  var b = parseInt(hex.slice(5, 7), 16)
  r = Math.floor(r + (255 - r) * percent)
  g = Math.floor(g + (255 - g) * percent)
  b = Math.floor(b + (255 - b) * percent)
  return "#" + r.toString(16).padStart(2,"0") + g.toString(16).padStart(2,"0") + b.toString(16).padStart(2,"0")
}

function formatTime(date) {
  return Qt.formatDateTime(date, "HH:mm")
}

function formatDate(date) {
  var days = ["воскресенье","понедельник","вторник","среда","четверг","пятница","суббота"]
  var months = ["января","февраля","марта","апреля","мая","июня","июля","августа","сентября","октября","ноября","декабря"]
  return days[date.getDay()] + ", " + date.getDate() + " " + months[date.getMonth()]
}

function truncate(text, maxLen) {
  if (!text) return ""
  if (text.length <= maxLen) return text
  return text.substring(0, maxLen) + "..."
}