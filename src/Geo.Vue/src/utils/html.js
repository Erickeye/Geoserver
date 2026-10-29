const ESCAPES = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;'
}

// 外部資料（站名、地址）進 HTML 字串前一律跳脫，避免 XSS
export function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, c => ESCAPES[c])
}
