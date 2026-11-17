// Область варианта 8679:
// 1-ая четверть: четверть круга радиуса R/2
// 2-ая четверть: прямоугольник со сторонами R по X и R/2 по Y
// 3-ая четверть: треугольник с катетами R/2 по X и R/2 по Y
export function drawShape(ctx, { centerX, centerY, scale, getStyleColor }) {
  ctx.fillStyle = getStyleColor("--graph-figure");

  // 1-ая четверть (круг радиуса R/2)
  ctx.beginPath();
  ctx.moveTo(centerX, centerY);
  ctx.arc(centerX, centerY, scale / 2, -Math.PI / 2, 0);
  ctx.closePath();
  ctx.fill();

  // 2-ая четверть (прямоугольник: от X=0 до -R, от Y=0 до -R/2)
  ctx.fillRect(centerX - scale, centerY, scale, scale / 2);

  // 3-ая четверть (треугольник: (0,0) -> (R/2, 0) -> (0, -R/2))
  ctx.beginPath();
  ctx.moveTo(centerX, centerY);
  ctx.lineTo(centerX + scale / 2, centerY);
  ctx.lineTo(centerX, centerY + scale / 2);
  ctx.closePath();
  ctx.fill();
}
