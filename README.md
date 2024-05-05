The idea:
1. read in absolute numbers
2. fit data to weibull based s-curve shape
3. take function from fit as extrapolation

In case of valley of death:
Specify capacity as function instead of it going asymptotically to 1.
Do the fit for BEV (increasing) and non-BEV (decreasing)
Compare sum of fitted functions to previously specified asymptote

EU numbers: https://docs.google.com/spreadsheets/d/17h0MJXfIJH4yn2Kk-vmS9Qx_bNJfXfCRqZjFS5__y0k/edit?usp=sharing

Note:
Code was built historically beginning with German data that took in FZ.10 files to read from there automatically.
Later took data from Scandinavia and went over to their formatting.
Years/Months are therefore formatted as YYYY+(MM-1)/12-1
This made it easier in earlier versions to deal with the time variable as it was numeric and meant each year marker marked the end of of said year instead of the beginning, which was an arbitrary choice for visual purposes.
In this version this could be done differently, but copy+paste from older versions is the lazy way and I went for that.
The back moving by the 1 year is done in code.

Some values are hardcoded because of similar reasons, since other countries share code but have different times that should be shown and visuals like boxes are easier hard coded than done by variables.

Always a work in progress.

If you take from me, please tell me.
Not because I'm against it. Rather I'd like to see what you did with it and if your output is be interesting.

