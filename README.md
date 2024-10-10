# ribbons
This processing program generates beautiful ribbon- or textile-like structures like this:

![Sample output 7](output_samples/output_2024-8-27_22-55-46.svg)

You can save them as an SVG-file, which lends itself for pen plotting very well.

It makes use of the BezierLineClass. So in order to make this work you need to copy the file bezierLineClass.pde from [BezierLineClass](https://github.com/mattack65/processing---bezierLineClass) into the same directory (or copy it into another directory and then make a symlink in the ribbon directory).
 
You can change the parameters starting around line 20 to change the style.

Use following keys to manipulate the images:

Hit "ENTER" to craete a new image

Hit "Space" to stop and start an animation

With the keys "+" and "-" you can increase or decrease the line density.

Hit "h" to show/hide the helper lines

Hit "s" to save yout image to an SVG-file

Hit "p" to show/hide the Bezier anchor points on the helper lines

Hit "t" to switch between straight lines and bezier lines

With "m" you can add some color.

To make an animation or a video, you need to un-comment a few lines, but I recommend to play around with the single images or animated images first.

The code creates one very long bezier curve (in the bezier mode). When you save it to a SVG-file ("s"), it will break it up into several paths (e.g. 3 or 4 paths), instead of one very long path. This will give you the opportunity, to plot one path, then re-fill ink or exchange the pen, and then continue with the next path. There is a parameter named max_path_length_in_m in the code, where you can set the max. length of each path. The multiple paths also make it very easy, if you want to plot part of the image in a different color, with another pen etc.

The total length of the line is printed out (println) after every generation of an image. The length is calculated, as if every pixel of the image were 1 mm. So if you set the canvas to 1000 x 800 and later plot it on a 1000 x 800 mm piece of paper, the length corresponds. If however you plot it on a smaller paper e.g. 250 x 200 mm, then you have to divide the line length by 4 (in this example) to get the real plotted line length. 

It's all very primitive and experimental. 

It needs a proper interface. Let me know if you run into any problems.

More samples:

![Sample output 1](output_samples/output_2024-8-21_21-17-58.svg)

![Sample output 2](output_samples/output_2024-8-21_23-48-6.svg)

![Sample output 3](output_samples/output_2024-8-22_2-4-18.svg)

![Sample output 4](output_samples/output_2024-8-22_2-38-34.svg)

![Sample output 5](output_samples/output_2024-8-23_23-1-21.svg)

![Sample output 6](output_samples/output_2024-8-23_23-49-12.svg)

![Sample output 8](output_samples/output_2024-8-27_23-3-25.svg)

![Sample output 9](output_samples/output_2024-8-27_23-16-22.svg)

![Sample output 10](output_samples/output_2024-9-20_23-44-0.svg)

