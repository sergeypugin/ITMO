const POINTS_KEY = "lab1_points";

export const Storage = {
  getPoints() {
    try {
      const data = localStorage.getItem(POINTS_KEY);
      return data ? JSON.parse(data) : [];
    } catch (e) {
      console.error("Ошибка чтения из LocalStorage:", e);
      return [];
    }
  },

  addPoint(point) {
    try {
      const points = this.getPoints();
      points.push(point);
      localStorage.setItem(POINTS_KEY, JSON.stringify(points));
    } catch (e) {
      console.error("Ошибка записи в LocalStorage:", e);
    }
  },

  clearPoints() {
    try {
      localStorage.removeItem(POINTS_KEY);
    } catch (e) {
      console.error("Ошибка очистки LocalStorage:", e);
    }
  },
};
