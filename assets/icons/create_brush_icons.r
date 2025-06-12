f <- function(x) -abs(x) + 1

par(mar = c(0, 0, 0, 0), bg = "white")
curve(f, from = -1, to = 1, n = 1000, col = "black", lwd = 25,
     xlab = "", ylab = "", axes = FALSE, ylim = c(-0.1, 1.1), xlim = c(-1.1, 1.1))

savePlot <- function(filename) {
  dev.copy(png, filename, width = 500, height = 500)
  dev.off()
}
savePlot("assets/icons/linear_brush_icon.png")

f <- function(x) x ^ 2 * -1
curve(f, from = -1, to = 1, n = 1000, col = "black", lwd = 25,
     xlab = "", ylab = "", axes = FALSE, ylim = c(-1.1, 0.1), xlim = c(-1.1, 1.1))
savePlot("assets/icons/quad_brush_icon.png")

f <- function(x) exp(-x ^ 2)
curve(f, from = -2, to = 2, n = 1000, col = "black", lwd = 25,
     xlab = "", ylab = "", axes = FALSE, ylim = c(-0.1, 1.1), xlim = c(-2.1, 2.1))
savePlot("assets/icons/gaussian_brush_icon.png")