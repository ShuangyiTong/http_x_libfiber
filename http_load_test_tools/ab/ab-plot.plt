# output as png image
set terminal png size 1280,720

gtitle = "Apache"
fext = ".png"
original_title = " - Response Time Distribution"
# save file to "benchmark.png"
set output gtitle.fext

# graph title
set title gtitle.original_title

#nicer aspect ratio for image size
set size 1,1

set multiplot

# y-axis grid
set grid y

#x-axis label
set xlabel "request"

set xrange [8000:10000]

#y-axis label
set ylabel "response time (ms)"

#plot data from "out.data" using column 9 with smooth sbezier lines
plot "apache-thread-worker.out" using 9 smooth sbezier with lines title "Apache/worker pthread" lw 3, \
"apache-thread-prefork.out" using 9 smooth sbezier with lines title "Apache/prefork pthread" lw 3, \
"apache-fiber-prefork.out" using 9 smooth sbezier with lines title "Apache/prefork libfiber" lw 3, \
"apache-thread-event.out" using 9 smooth sbezier with lines title "Apache/event pthread" lw 3, \
     "apache-fiber-worker.out" using 9 smooth sbezier with lines title "Apache/worker libfiber" lw 3
