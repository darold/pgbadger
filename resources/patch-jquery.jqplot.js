--- resources/jquery.jqplot.js.orig	2016-08-30 18:50:53.056335603 +0200
+++ resources/jquery.jqplot.js	2016-08-30 18:51:33.211372314 +0200
@@ -9139,7 +9139,7 @@
 
             for (var i=0; i<wl; i++) {
                 w += words[i];
-                if (context.measureText(w).width > tagwidth) {
+                if (context.measureText(w).width > tagwidth && w.length > words[i].length) {
                     breaks.push(i);
                     w = '';
                     i--;
