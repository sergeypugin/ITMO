package app.model;

import java.io.Serializable;

public final class Point implements Serializable {
    private static final long serialVersionUID = 1L;
    private final double x;
    private final double y;
    private final double r;

    public Point(double x, double y, double r) {
        this.x = x;
        this.y = y;
        this.r = r;
    }

    public double getX() {
        return x;
    }

    public double getY() {
        return y;
    }

    public double getR() {
        return r;
    }
}
