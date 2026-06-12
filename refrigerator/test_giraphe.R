library(tidyverse)

library(marmap)
data(celt)
plot(celt)
#locator() -> samples
#samples <- data.frame(samples)

gg_celt <- autoplot.bathy(celt, geom=c("tile","contour")) +
  scale_fill_gradient2(low="dodgerblue4", mid="gainsboro", high="darkgreen") +
  geom_point_interactive(data = samples, aes(x = x, y = y),
             colour = 'blue', alpha = 1, shape = 1) +
  labs(y = "Latitude", x = "Longitude", fill = "Depth") +
  coord_cartesian(expand = 0) +
  ggtitle("A marmap map with ggplot2 and ggiraphe") 

gg_celt

z <- girafe_defaults()
z$opts_hover$css

css_default_hover <- girafe_css_bicolor(primary = "yellow", secondary = "red")

set_girafe_defaults(
  opts_hover = opts_hover(css = css_default_hover),
  opts_zoom = opts_zoom(min = 1, max = 4),
  opts_tooltip = opts_tooltip(css = "padding:3px;background-color:#333333;color:white;"),
  opts_sizing = opts_sizing(rescale = TRUE),
  opts_toolbar = opts_toolbar(saveaspng = FALSE, position = "bottom", delay_mouseout = 5000)
)

girafe(ggobj = gg_celt)
