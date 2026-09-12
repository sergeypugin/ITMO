const CONFIG = {
  padding: 24, // Отступ осей от края холста
  arrowSize: 8, // Длина наконечника стрелки
  arrowHalfWidth: 4, // Полуширина наконечника стрелки
  tickSize: 4, // Полудлина засечки на оси
  scale: 140, // Масштаб радиуса R в пикселях от центра
  labelOffset: 16, // Отступ подписей координат от засечек
  font: "12px sans-serif",
  pointRadius: 3.5,
  lastPointRadius: 5.5,
  pointLineWidth: 0.5,
  lastPointLineWidth: 1.5,
};

function getStyleColor(variableName, fallback) {
  return (
    getComputedStyle(document.documentElement)
      .getPropertyValue(variableName)
      .trim() || fallback
  );
}

export function renderCanvas(rValue = null, points = []) {
  const canvas = document.getElementById("graph");
  const ctx = canvas.getContext("2d");
  const WIDTH = canvas.width;
  const HEIGHT = canvas.height;
  const CENTER_X = WIDTH / 2;
  const CENTER_Y = HEIGHT / 2;

  ctx.clearRect(0, 0, WIDTH, HEIGHT);
  drawShapes();
  drawAxes(rValue);
  drawPoints(rValue, points);

  function drawShapes() {
    ctx.fillStyle = getStyleColor("--graph-figure", "rgba(37, 99, 235, 0.45)");

    // 1-я четверть: сектор круга радиуса R/2 (от 0 до -PI/2)
    ctx.beginPath();
    ctx.moveTo(CENTER_X, CENTER_Y);
    ctx.arc(CENTER_X, CENTER_Y, CONFIG.scale / 2, 0, -Math.PI / 2, true);
    ctx.closePath();
    ctx.fill();

    // 2-я четверть: прямоугольный треугольник ((0,0), (-R/2, 0), (0, R))
    ctx.beginPath();
    ctx.moveTo(CENTER_X, CENTER_Y);
    ctx.lineTo(CENTER_X - CONFIG.scale / 2, CENTER_Y);
    ctx.lineTo(CENTER_X, CENTER_Y - CONFIG.scale);
    ctx.closePath();
    ctx.fill();

    // 4-я четверть: прямоугольник шириной R и высотой R
    ctx.fillRect(CENTER_X, CENTER_Y, CONFIG.scale, CONFIG.scale);
  }

  function drawAxes(rValue = null) {
    const textColor = getStyleColor("--text-main", "#0f172a");
    const axesColor = getStyleColor("--text-main", "#0f172a");

    ctx.strokeStyle = axesColor;
    ctx.fillStyle = textColor;
    ctx.lineWidth = 1.5;
    ctx.font = CONFIG.font;
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    // Горизонтальная ось X со стрелкой
    ctx.beginPath();
    ctx.moveTo(CONFIG.padding, CENTER_Y);
    ctx.lineTo(WIDTH - CONFIG.padding, CENTER_Y);
    ctx.lineTo(
      WIDTH - CONFIG.padding - CONFIG.arrowSize,
      CENTER_Y - CONFIG.arrowHalfWidth,
    );
    ctx.moveTo(WIDTH - CONFIG.padding, CENTER_Y);
    ctx.lineTo(
      WIDTH - CONFIG.padding - CONFIG.arrowSize,
      CENTER_Y + CONFIG.arrowHalfWidth,
    );

    // Вертикальная ось Y со стрелкой
    ctx.moveTo(CENTER_X, HEIGHT - CONFIG.padding);
    ctx.lineTo(CENTER_X, CONFIG.padding);
    ctx.lineTo(
      CENTER_X - CONFIG.arrowHalfWidth,
      CONFIG.padding + CONFIG.arrowSize,
    );
    ctx.moveTo(CENTER_X, CONFIG.padding);
    ctx.lineTo(
      CENTER_X + CONFIG.arrowHalfWidth,
      CONFIG.padding + CONFIG.arrowSize,
    );
    ctx.stroke();

    ctx.fillText("x", WIDTH - CONFIG.padding / 2, CENTER_Y - 12);
    ctx.fillText("y", CENTER_X + 12, CONFIG.padding / 2);

    // Метки R на засечках
    const rLabel = rValue ? rValue : "R";
    const halfRLabel = rValue ? rValue / 2 : "R/2";

    const marks = [
      { dx: -CONFIG.scale, dy: 0, text: `-${rLabel}` },
      { dx: -CONFIG.scale / 2, dy: 0, text: `-${halfRLabel}` },
      { dx: CONFIG.scale / 2, dy: 0, text: `${halfRLabel}` },
      { dx: CONFIG.scale, dy: 0, text: `${rLabel}` },
      { dx: 0, dy: -CONFIG.scale, text: `${rLabel}` },
      { dx: 0, dy: -CONFIG.scale / 2, text: `${halfRLabel}` },
      { dx: 0, dy: CONFIG.scale / 2, text: `-${halfRLabel}` },
      { dx: 0, dy: CONFIG.scale, text: `-${rLabel}` },
    ];

    ctx.beginPath();
    marks.forEach((mark) => {
      const x = CENTER_X + mark.dx;
      const y = CENTER_Y + mark.dy;

      if (mark.dy === 0) {
        ctx.moveTo(x, CENTER_Y - CONFIG.tickSize);
        ctx.lineTo(x, CENTER_Y + CONFIG.tickSize);
        ctx.fillText(mark.text, x, CENTER_Y + CONFIG.labelOffset);
      } else {
        ctx.moveTo(CENTER_X - CONFIG.tickSize, y);
        ctx.lineTo(CENTER_X + CONFIG.tickSize, y);
        ctx.fillText(mark.text, CENTER_X - (CONFIG.labelOffset + 4), y);
      }
    });
    ctx.stroke();
  }

  function drawPoints(rValue, points) {
    if (!rValue || !points || points.length === 0) return;

    const green = getStyleColor("--color-green", "#16a34a");
    const red = getStyleColor("--color-red", "#dc2626");
    const textColor = getStyleColor("--text-main", "#0f172a");

    points.forEach((p, index) => {
      const canvasX = CENTER_X + (p.x / rValue) * CONFIG.scale;
      const canvasY = CENTER_Y - (p.y / rValue) * CONFIG.scale;
      const isLast = index === points.length - 1;
      ctx.beginPath();
      ctx.arc(
        canvasX,
        canvasY,
        isLast ? CONFIG.lastPointRadius : CONFIG.pointRadius,
        0,
        2 * Math.PI,
      );
      ctx.fillStyle = p.hit ? green : red;
      ctx.fill();
      ctx.strokeStyle = textColor;
      ctx.lineWidth = isLast
        ? CONFIG.lastPointLineWidth
        : CONFIG.pointLineWidth;
      ctx.stroke();
    });
  }
}
