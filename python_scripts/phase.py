
import matplotlib.pyplot as plt
import nmrglue as ng
import matplotlib
import numpy as np
from scipy.signal import hilbert
from matplotlib.widgets import Slider, Button

# plot parameters these should be changed by the user if needed
spectrum = 'test.ft2'
cmap = matplotlib.cm.Blues_r    # contour map (colors to use for contours)

contour_start = 100000000000           # contour level start value
contour_num = 50                # number of contour levels
contour_factor = 1.25          # scaling factor between contour levels
contour_line_width = 0.4
slice_width = 1
xslice_factor = 4.e10 
yslice_factor = 4.e11 
slider_multiplier = 20 
xp0_val = None
xp1_val = None

yp0_val = None
yp1_val = None

# calculate contour levels
cl = contour_start * contour_factor ** np.arange(contour_num)
# read in the data from a NMRPipe file
dic, data = ng.pipe.read(spectrum)
#data = hilbert(data)


def onclick(event):

    if dim_ppm_limits[1][0] > event.xdata > dim_ppm_limits[1][1]:
        if dim_ppm_limits[0][0] > event.ydata > dim_ppm_limits[0][1]:
                global ix, iy 
                ix = event.xdata
                iy = event.ydata
                print(f'x: {ix:0.2}ppm  y:{iy:0.2}ppm')
                ix, iy = event.xdata, event.ydata
                xslice = data[dim_uc[0](f'{iy} ppm'), :]
                plot_xslice.set_xdata(dim_ppm_scale[1])
                plot_xslice.set_ydata(-xslice / x_intensity.val+iy)

                yslice = data[:,dim_uc[1](f'{ix} ppm')]
                plot_yslice.set_ydata(dim_ppm_scale[0])
                plot_yslice.set_xdata(-yslice / y_intensity.val+ix)
                fig.canvas.draw_idle()


def update(val):


    xslice = data[dim_uc[0](f'{iy} ppm'), :]
    xslice = hilbert(xslice)
    di, xslice = ng.pipe_proc.ps(dic, xslice, p0=x_p0_slider.val, p1=x_p1_slider.val)
    plot_xslice.set_ydata(-xslice / x_intensity.val+ iy)

    yslice = data[:,dim_uc[1](f'{ix} ppm')]
    yslice = hilbert(yslice)
    di, yslice = ng.pipe_proc.ps(dic, yslice, p0=y_p0_slider.val, p1=y_p1_slider.val)
    plot_yslice.set_xdata( -yslice / y_intensity.val + ix)
    fig.canvas.draw_idle()


# make ppm scales
dim_uc = {}
dim_ppm_scale = {}
dim_ppm_limits = {}

for i in range(len(data.shape)):

    dim_uc[i] = ng.pipe.make_uc(dic, data, dim=i)
    dim_ppm_scale[i] = dim_uc[i].ppm_scale()
    dim_ppm_limits[i] = dim_uc[i].ppm_limits()
# create the figure

fig, ax= plt.subplots(1, 1)
fig.set_figheight(8)
fig.set_figwidth(13)

axp0 = plt.axes([0.12, 0.0, 0.2, 0.03])
x_intensity = Slider(
    ax=axp0,
    label='x int',
    valmin=0,
    valmax=xslice_factor*slider_multiplier,
    valinit=xslice_factor,
)

axp0 = plt.axes([0.12, 0.03, 0.2, 0.03])
y_intensity = Slider(
    ax=axp0,
    label='y int',
    valmin=0,
    valmax=yslice_factor*slider_multiplier,
    valinit=yslice_factor,
)

axp0 = plt.axes([0.4, 0.0, 0.2, 0.03])
x_p1_slider = Slider(
    ax=axp0,
    label='xp1',
    valmin=-360,
    valmax=360,
    valinit=0,
)

axp0 = plt.axes([0.4, 0.03, 0.2, 0.03])
x_p0_slider = Slider(
    ax=axp0,
    label='xp0',
    valmin=-360,
    valmax=360,
    valinit=0,
)

axp0 = plt.axes([0.68, 0.0, 0.2, 0.03])
y_p1_slider = Slider(
    ax=axp0,
    label='yp1',
    valmin=-360,
    valmax=360,
    valinit=0,
)

axp0 = plt.axes([0.68, 0.03, 0.2, 0.03])
y_p0_slider = Slider(
    ax=axp0,
    label='yp0',
    valmin=-360,
    valmax=360,
    valinit=0,
)


# plot the contours
ax.contour(data, cl, cmap=cmap,
            extent=(dim_ppm_limits[1][0], dim_ppm_limits[1][1], dim_ppm_limits[0][0], dim_ppm_limits[0][1]), 
            zorder=2, linewidths=contour_line_width)

# plot slices in each direction
iy = np.mean(dim_ppm_limits[0])
ix = np.mean(dim_ppm_limits[1])
xslice = data[dim_uc[0](f'{iy} ppm'), :]
plot_xslice,  = ax.plot(dim_ppm_scale[1], -xslice / xslice_factor+ iy, zorder=1)

yslice = data[:,dim_uc[1](f'{ix} ppm')]
plot_yslice, = ax.plot( -yslice / yslice_factor + ix, dim_ppm_scale[0], zorder=1)

ax.set_xlim(dim_ppm_limits[1][0], dim_ppm_limits[1][1])
ax.set_ylim(dim_ppm_limits[0][0], dim_ppm_limits[0][1])
x_intensity.on_changed(update)
y_intensity.on_changed(update)
x_p0_slider.on_changed(update)
x_p1_slider.on_changed(update)
y_p0_slider.on_changed(update)
y_p1_slider.on_changed(update)

cid = fig.canvas.mpl_connect('button_press_event', onclick)
plt.xlabel('1H (ppm)')
plt.ylabel('13C (ppm)')
plt.show()