// Отрисовка графика области: оси, подписи и точки общие,
// а фигуру варианта рисует сама лаба через drawShape.
const CONFIG = {
  padding: 24, // Отступ осей от края холста
  arrowSize: 8, // Длина наконечника стрелки
  arrowHalfWidth: 4, // Полуширина наконечника стрелки
  tickSize: 4, // Полудлина засечки на оси
  scale: 175, // Масштаб радиуса R в пикселях от центра
  labelOffset: 16, // Отступ подписей координат от засечек
  font: '700 12px "Nunito", "Segoe UI", sans-serif',
  pointRadius: 3.5,
  lastPointRadius: 5.5,
  pointLineWidth: 0.5,
  lastPointLineWidth: 1.5,
};

const numberFormatter = new Intl.NumberFormat("ru-RU", { maximumFractionDigits: 2 });

let colorProbe = null;

// getComputedStyle возвращает custom property как есть (вместе с var(...)),
// поэтому цвет разрешается через временный элемент и реальное свойство color.
function getStyleColor(variableName) {
  if (!colorProbe) {
    colorProbe = document.createElement("span");
    colorProbe.style.display = "none";
    document.body.append(colorProbe);
  }

  colorProbe.style.color = `var(${variableName})`;
  return getComputedStyle(colorProbe).color;
}

// Рисует область варианта, оси и точки истории.
export function renderGraph({
  canvasId = "graph",
  scale = CONFIG.scale,
  radius = Number.NaN,
  points = [],
  drawShape = () => {},
}) {
  const canvas = document.getElementById(canvasId);

  if (!canvas) {
    return;
  }

  const ctx = canvas.getContext("2d");
  const WIDTH = canvas.width;
  const HEIGHT = canvas.height;
  const CENTER_X = WIDTH / 2;
  const CENTER_Y = HEIGHT / 2;

  const hasR = Number.isFinite(radius);

  ctx.clearRect(0, 0, WIDTH, HEIGHT);
  drawShape(ctx, { centerX: CENTER_X, centerY: CENTER_Y, scale, getStyleColor });
  drawAxes();
  drawPoints();

  function drawAxes() {
    const axesColor = getStyleColor("--text-main");

    ctx.strokeStyle = axesColor;
    ctx.fillStyle = axesColor;
    ctx.lineWidth = 1.5;
    ctx.font = CONFIG.font;
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    ctx.beginPath();
    ctx.moveTo(CONFIG.padding, CENTER_Y);
    ctx.lineTo(WIDTH - CONFIG.padding, CENTER_Y);
    ctx.lineTo(WIDTH - CONFIG.padding - CONFIG.arrowSize, CENTER_Y - CONFIG.arrowHalfWidth);
    ctx.moveTo(WIDTH - CONFIG.padding, CENTER_Y);
    ctx.lineTo(WIDTH - CONFIG.padding - CONFIG.arrowSize, CENTER_Y + CONFIG.arrowHalfWidth);

    ctx.moveTo(CENTER_X, HEIGHT - CONFIG.padding);
    ctx.lineTo(CENTER_X, CONFIG.padding);
    ctx.lineTo(CENTER_X - CONFIG.arrowHalfWidth, CONFIG.padding + CONFIG.arrowSize);
    ctx.moveTo(CENTER_X, CONFIG.padding);
    ctx.lineTo(CENTER_X + CONFIG.arrowHalfWidth, CONFIG.padding + CONFIG.arrowSize);
    ctx.stroke();

    ctx.fillText("x", WIDTH - CONFIG.padding / 2, CENTER_Y - 12);
    ctx.fillText("y", CENTER_X + 12, CONFIG.padding / 2);

    const marks = [
      { dx: -scale, dy: 0, factor: -1 },
      { dx: -scale / 2, dy: 0, factor: -0.5 },
      { dx: scale / 2, dy: 0, factor: 0.5 },
      { dx: scale, dy: 0, factor: 1 },
      { dx: 0, dy: -scale, factor: 1 },
      { dx: 0, dy: -scale / 2, factor: 0.5 },
      { dx: 0, dy: scale / 2, factor: -0.5 },
      { dx: 0, dy: scale, factor: -1 },
    ];

    ctx.beginPath();
    marks.forEach((mark) => {
      const x = CENTER_X + mark.dx;
      const y = CENTER_Y + mark.dy;
      const text = markLabel(mark.factor);

      if (mark.dy === 0) {
        ctx.moveTo(x, CENTER_Y - CONFIG.tickSize);
        ctx.lineTo(x, CENTER_Y + CONFIG.tickSize);
        ctx.fillText(text, x, CENTER_Y + CONFIG.labelOffset);
      } else {
        ctx.moveTo(CENTER_X - CONFIG.tickSize, y);
        ctx.lineTo(CENTER_X + CONFIG.tickSize, y);
        ctx.fillText(text, CENTER_X - (CONFIG.labelOffset + 4), y);
      }
    });
    ctx.stroke();
  }

  function markLabel(factor) {
    if (!hasR) {
      if (factor === 1) return "R";
      if (factor === 0.5) return "R/2";
      if (factor === -1) return "-R";
      return "-R/2";
    }
    return numberFormatter.format(radius * factor);
  }

  function drawPoints() {
    if (points.length === 0 || !hasR) {
      return;
    }

    const green = getStyleColor("--color-green");
    const red = getStyleColor("--color-red");
    const textColor = getStyleColor("--text-main");

    points.forEach((point, index) => {
      const canvasX = CENTER_X + (point.x / radius) * scale;
      const canvasY = CENTER_Y - (point.y / radius) * scale;
      const isLast = index === points.length - 1;

      ctx.beginPath();
      ctx.arc(
        canvasX,
        canvasY,
        isLast ? CONFIG.lastPointRadius : CONFIG.pointRadius,
        0,
        2 * Math.PI,
      );
      ctx.fillStyle = point.hit ? green : red;
      ctx.fill();
      ctx.strokeStyle = textColor;
      ctx.lineWidth = isLast ? CONFIG.lastPointLineWidth : CONFIG.pointLineWidth;
      ctx.stroke();
    });
  }
}
