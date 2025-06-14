f <- function(x) -abs(x) + 1

par(mar = c(0, 0, 0, 0), bg = "white")
plot_f <- function() curve(f, from = -1, to = 1, n = 1000, col = "black", lwd = 25,
     xlab = "", ylab = "", axes = FALSE, ylim = c(-0.1, 1.1), xlim = c(-1.1, 1.1))

savePlot <- function(filename) {
  dev.copy(png, filename, width = 500, height = 500)
  dev.off()
}

plot_f()
savePlot("assets/icons/linear_brush_icon.png")

g <- function(x) x ^ 2 * -1
plot_g <- function() curve(g, from = -1, to = 1, n = 1000, col = "black", lwd = 25,
     xlab = "", ylab = "", axes = FALSE, ylim = c(-1.1, 0.1), xlim = c(-1.1, 1.1))

plot_g()
savePlot("assets/icons/quad_brush_icon.png")

h <- function(x) exp(-x ^ 2)
plot_h <- function() curve(h, from = -2, to = 2, n = 1000, col = "black", lwd = 25,
     xlab = "", ylab = "", axes = FALSE, ylim = c(-0.1, 1.1), xlim = c(-2.1, 2.1))

plot_h()
savePlot("assets/icons/gaussian_brush_icon.png")

par(mar = c(0, 0, 0, 0), bg = "grey")
plot_f()
savePlot("assets/icons/linear_brush_icon_grey.png")
plot_g()
savePlot("assets/icons/quad_brush_icon_grey.png")
plot_h()
savePlot("assets/icons/gaussian_brush_icon_grey.png")