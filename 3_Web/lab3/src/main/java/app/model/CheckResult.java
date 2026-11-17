package app.model;

import java.io.Serializable;
import java.util.Date;

public final class CheckResult implements Serializable {
    private static final long serialVersionUID = 1L;

    private final Point point;
    private final boolean hit;
    private final Date checkedAt;
    private final double executionTimeMs;

    public CheckResult() {
        this(new Point(0, 0, 0), false, new Date(), 0);
    }

    public CheckResult(Point point, boolean hit, Date checkedAt, double executionTimeMs) {
        this.point = point;
        this.hit = hit;
        this.checkedAt = new Date(checkedAt.getTime());
        this.executionTimeMs = executionTimeMs;
    }

    public double getX() {
        return point.getX();
    }

    public double getY() {
        return point.getY();
    }

    public double getR() {
        return point.getR();
    }

    public Point getPoint() {
        return point;
    }

    public boolean isHit() {
        return hit;
    }

    public Date getCheckedAt() {
        return new Date(checkedAt.getTime());
    }

    public double getExecutionTimeMs() {
        return executionTimeMs;
    }
}
