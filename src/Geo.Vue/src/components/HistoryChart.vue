<script setup>
import { computed } from 'vue'

const props = defineProps({
  // [{ recordedAt, bikes, docks }]，由舊到新；只含數量有變動的時間點
  points: { type: Array, default: () => [] },
  total: { type: Number, default: 0 },
  hours: { type: Number, default: 24 }
})

const WIDTH = 296
const HEIGHT = 120
const PAD = { left: 28, right: 6, top: 8, bottom: 18 }

const plotW = WIDTH - PAD.left - PAD.right
const plotH = HEIGHT - PAD.top - PAD.bottom

const range = computed(() => {
  const end = Date.now()
  return { start: end - props.hours * 3600000, end }
})

const yMax = computed(() => Math.max(props.total, ...props.points.map(p => p.bikes), 1))

function xOf(time) {
  const { start, end } = range.value
  return PAD.left + ((Math.max(time, start) - start) / (end - start)) * plotW
}

function yOf(value) {
  return PAD.top + plotH - (value / yMax.value) * plotH
}

// 數量只在變動時才有紀錄，所以畫成階梯線：每個點的值維持到下一個點，最後一點延伸到現在
const path = computed(() => {
  const times = props.points.map(p => new Date(p.recordedAt).getTime())
  const segments = []

  props.points.forEach((p, i) => {
    const x = xOf(times[i])
    const y = yOf(p.bikes)
    segments.push(i === 0 ? `M${x},${y}` : `H${x}V${y}`)
  })

  if (props.points.length > 0) {
    segments.push(`H${xOf(range.value.end)}`)
  }

  return segments.join('')
})

const yTicks = computed(() => [0, Math.round(yMax.value / 2), yMax.value])

const xLabels = computed(() => {
  const fmt = new Intl.DateTimeFormat('zh-TW', {
    timeZone: 'Asia/Taipei',
    hour12: false,
    ...(props.hours > 24 ? { month: 'numeric', day: 'numeric' } : { hour: '2-digit', minute: '2-digit' })
  })
  return [range.value.start, range.value.end].map(t => fmt.format(t))
})
</script>

<template>
  <div class="chart">
    <div v-if="points.length === 0" class="empty">這段期間沒有紀錄（快照剛開始累積）</div>
    <svg v-else :viewBox="`0 0 ${WIDTH} ${HEIGHT}`" role="img" aria-label="可借車輛數變化">
      <g v-for="tick in yTicks" :key="tick">
        <line :x1="PAD.left" :x2="WIDTH - PAD.right" :y1="yOf(tick)" :y2="yOf(tick)" class="grid" />
        <text :x="PAD.left - 4" :y="yOf(tick) + 3" class="tick" text-anchor="end">{{ tick }}</text>
      </g>
      <path :d="path" class="line" />
      <text :x="PAD.left" :y="HEIGHT - 4" class="tick">{{ xLabels[0] }}</text>
      <text :x="WIDTH - PAD.right" :y="HEIGHT - 4" class="tick" text-anchor="end">{{ xLabels[1] }}</text>
    </svg>
  </div>
</template>

<style scoped>
.chart svg {
  width: 100%;
  height: auto;
  display: block;
}

.empty {
  color: #666;
  font-size: 12px;
  padding: 8px 0;
}

.grid {
  stroke: #e0e0e0;
  stroke-width: 1;
}

.tick {
  font-size: 9px;
  fill: #666;
}

.line {
  fill: none;
  stroke: #1565c0;
  stroke-width: 2;
  stroke-linejoin: round;
}
</style>
