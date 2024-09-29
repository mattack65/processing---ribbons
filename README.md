# ribbons
This processing program generates beautiful ribbon- or textile-like structures.

It makes use of the BezierLineClass. So in order to make this work you need to copy the file bezierLineClass.pde from [BezierLineClass](https://github.com/mattack65/processing---bezierLineClass) into the same directory (or copy it into another directory and then make a symlink in the ribbon directory).
 
You can change the parameters starting around line 20 to change the appearance.

Every time you click the left mouse button, a new image is created.

With the keys "+" and "-" you can increase or decrease the line density.

With the middle mouse button you can show and hide the guidelines.

With the right mouse button you can save it as an SVG.

With "m" you can add some color.

To make an actual animation, you need to un-comment a few lines, but I recommend to play around with the single images first.

The code creates one very long bezier curve. When you save it to a SVG-file (right mouse button), it will break in up into several paths (e.g. 3 or 4 paths), instead of one very long path. This will give you the opportunity, to plot one path, then re-fill ink or exchange the pen, and then continue with the next path. There is a parameter somewhere in the code, where you can set the max. length of each path. The multiple paths also make it very easy, if you want to plot part of the image in a different color, with another pen etc.

The total length of the line is printed out (println) after every generation of an image. The length is calculated, as if every pixel of the image were 1 mm. So if you set the canvas to 1000 x 800 and later plot it on a 1000 x 800 mm piece of paper, the length corresponds. If however you then plot it on a smaller paper e.g. 250 x 200 mm, then you have to divide the line length by 4 to get the real plotted line length. 

It's all very primitive and experimental. 

It needs a proper interface. Let me know if you run into any problems.

![Sample output 1](output_samples/output_2024-8-21_21-17-58.svg)

![Sample output 2](output_samples/output_2024-8-21_23-48-6.svg)

![Sample output 3](output_samples/output_2024-8-22_2-4-18.svg)

![Sample output 4](output_samples/output_2024-8-22_2-38-34.svg)

![Sample output 5](output_samples/output_2024-8-23_23-1-21.svg)

![Sample output 6](output_samples/output_2024-8-23_23-49-12.svg)

![Sample output 7](output_samples/output_2024-8-27_22-55-46.svg)

![Sample output 8](output_samples/output_2024-8-27_23-3-25.svg)

![Sample output 9](output_samples/output_2024-8-27_23-16-22.svg)

![Sample output 10](output_samples/output_2024-9-20_23-44-0.svg)

