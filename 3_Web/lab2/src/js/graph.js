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

let colorProbe = null;

/**
 * Значение CSS-переменной в виде, пригодном для canvas.
 *
 * getComputedStyle возвращает кастомное свойство как есть, вместе с вложенными
 * var(...), поэтому цвет разрешается через реальное свойство color.
 */
function getStyleColor(variableName) {
  if (!colorProbe) {
    colorProbe = document.createElement("span");
    colorProbe.style.display = "none";
    document.body.append(colorProbe);
  }

  colorProbe.style.color = `var(${variableName})`;
  return getComputedStyle(colorProbe).color;
}

/**
 * Рисует область варианта и точки истории.
 *
 * Область задана относительно R, поэтому и точки нормируются на свой R:
 * точка на границе своей области всегда попадает на границу фигуры.
 */
export function renderCanvas(points = []) {
  const canvas = document.getElementById("graph");
  const ctx = canvas.getContext("2d");
  const WIDTH = canvas.width;
  const HEIGHT = canvas.height;
  const CENTER_X = WIDTH / 2;
  const CENTER_Y = HEIGHT / 2;

  ctx.clearRect(0, 0, WIDTH, HEIGHT);
  drawShapes();
  drawAxes();
  drawPoints(points);

  function drawShapes() {
    ctx.fillStyle = getStyleColor("--graph-figure");

    // II четверть: четверть круга радиуса R
    ctx.beginPath();
    ctx.moveTo(CENTER_X, CENTER_Y);
    ctx.arc(CENTER_X, CENTER_Y, CONFIG.scale, Math.PI, 1.5 * Math.PI);
    ctx.closePath();
    ctx.fill();

    // III четверть: квадрат со стороной R
    ctx.fillRect(CENTER_X - CONFIG.scale, CENTER_Y, CONFIG.scale, CONFIG.scale);

    // IV четверть: треугольник (0, 0), (R/2, 0), (0, -R)
    ctx.beginPath();
    ctx.moveTo(CENTER_X, CENTER_Y);
    ctx.lineTo(CENTER_X + CONFIG.scale / 2, CENTER_Y);
    ctx.lineTo(CENTER_X, CENTER_Y + CONFIG.scale);
    ctx.closePath();
    ctx.fill();
  }

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
      { dx: -CONFIG.scale, dy: 0, text: "-R" },
      { dx: -CONFIG.scale / 2, dy: 0, text: "-R/2" },
      { dx: CONFIG.scale / 2, dy: 0, text: "R/2" },
      { dx: CONFIG.scale, dy: 0, text: "R" },
      { dx: 0, dy: -CONFIG.scale, text: "R" },
      { dx: 0, dy: -CONFIG.scale / 2, text: "R/2" },
      { dx: 0, dy: CONFIG.scale / 2, text: "-R/2" },
      { dx: 0, dy: CONFIG.scale, text: "-R" },
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

  function drawPoints(points) {
    if (!points || points.length === 0) {
      return;
    }

    const green = getStyleColor("--color-green");
    const red = getStyleColor("--color-red");
    const textColor = getStyleColor("--text-main");

    points.forEach((point, index) => {
      const canvasX = CENTER_X + (point.x / point.r) * CONFIG.scale;
      const canvasY = CENTER_Y - (point.y / point.r) * CONFIG.scale;
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
