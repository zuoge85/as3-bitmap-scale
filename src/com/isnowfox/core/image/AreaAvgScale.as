package com.isnowfox.core.image
{
    import flash.display.BitmapData
    import flash.geom.Rectangle

    /**
     *
     * @author zuoge85 on 2014/7/13.
     */
    public class AreaAvgScale
    {
        private static const reds:Vector.<Number> = new <Number>[];
        private static const greens:Vector.<Number> = new <Number>[];
        private static const blues:Vector.<Number> = new <Number>[];
        private static const alphas:Vector.<Number> = new <Number>[];
        private static const outpixbuf:Vector.<uint> = new <uint>[];

        public function AreaAvgScale()
        {

        }

        [Inline]
        private static function makeAccumBuffers(destWidth:int):void
        {
            reds.fixed = false;
            reds.length = destWidth;
            reds.fixed = true;

            greens.fixed = false;
            greens.length = destWidth;
            greens.fixed = true;

            blues.fixed = false;
            blues.length = destWidth;
            blues.fixed = true;

            alphas.fixed = false;
            alphas.length = destWidth;
            alphas.fixed = true;

            outpixbuf.fixed = false;
            outpixbuf.length = destWidth;
            outpixbuf.fixed = true;
        }

        public static function scale(bitmapData:BitmapData, destWidth:int, destHeight:int):BitmapData
        {
            const srcWidth:int = bitmapData.width;
            const srcHeight:int = bitmapData.height;
            const result:BitmapData = new BitmapData(destWidth, destHeight, true);

            makeAccumBuffers(destWidth);
            var sy:int = 0;
            var syrem:int = destHeight;
            var dy:int = 0, dyrem:int = 0;
            while (sy < srcHeight)
            {
                var amty:int;
                if (dyrem == 0)
                {
                    for (var i:int = 0; i < destWidth; i++)
                    {
                        alphas[i] = reds[i] = greens[i] = blues[i] = 0;
                    }
                    dyrem = srcHeight;
                }
                if (syrem < dyrem)
                {
                    amty = syrem;
                }
                else
                {
                    amty = dyrem;
                }
                var sx:int = 0;
                var dx:int = 0;
                var sxrem:int = 0;
                var dxrem:int = srcWidth;
                var a:Number = 0, r:Number = 0, g:Number = 0, b:Number = 0;
                while (sx < srcWidth)
                {
                    if (sxrem == 0)
                    {
                        sxrem = destWidth;
                        var rgb:uint;
                        rgb = bitmapData.getPixel32(sx, sy)
                        a = rgb >>> 24;
                        r = (rgb >> 16) & 0xff;
                        g = (rgb >> 8) & 0xff;
                        b = rgb & 0xff;
                        // premultiply the components if necessary
                        if (a != 255.0)
                        {
                            var ascale:Number = a / 255.0;
                            r *= ascale;
                            g *= ascale;
                            b *= ascale;
                        }
                    }
                    var amtx:int;
                    if (sxrem < dxrem)
                    {
                        amtx = sxrem;
                    }
                    else
                    {
                        amtx = dxrem;
                    }
                    var mult:Number = (Number(amtx)) * amty;
                    alphas[dx] += mult * a;
                    reds[dx] += mult * r;
                    greens[dx] += mult * g;
                    blues[dx] += mult * b;
                    if ((sxrem -= amtx) == 0)
                    {
                        sx++;
                    }
                    if ((dxrem -= amtx) == 0)
                    {
                        dx++;
                        dxrem = srcWidth;
                    }
                }
                if ((dyrem -= amty) == 0)
                {
                    row(outpixbuf, srcWidth, srcHeight, destWidth);
                    do {
                        result.setVector(new Rectangle(0, dy, destWidth, 1), outpixbuf);
                        dy++;
                    } while ((syrem -= amty) >= amty && amty == srcHeight);
                }
                else
                {
                    syrem -= amty;
                }
                if (syrem == 0)
                {
                    syrem = destHeight;
                    sy++;
                }
            }
            return result;
        }

        [Inline]
        private static function row(row:Vector.<uint>, srcWidth:int, srcHeight:int, destWidth:int):void
        {
            var origmult:Number = (Number(srcWidth)) * srcHeight;
//            var outpix:Vector.<uint> = Vector.<uint>(outpixbuf);
            for (var x:int = 0; x < destWidth; x++)
            {
                var mult:Number = origmult;
                var a:int = Math.round(alphas[x] / mult);
                if (a <= 0)
                {
                    a = 0;
                }
                else if (a >= 255)
                {
                    a = 255;
                }
                else
                {
                    // un-premultiply the components (by modifying mult here, we
                    // are effectively doing the divide by mult and divide by
                    // alpha in the same step)
                    mult = alphas[x] / 255;
                }
                var r:int = Math.round(reds[x] / mult);
                var g:int = Math.round(greens[x] / mult);
                var b:int = Math.round(blues[x] / mult);
                if (r < 0)
                {
                    r = 0;
                }
                else if (r > 255)
                {
                    r = 255;
                }
                if (g < 0)
                {
                    g = 0;
                }
                else if (g > 255)
                {
                    g = 255;
                }
                if (b < 0)
                {
                    b = 0;
                }
                else if (b > 255)
                {
                    b = 255;
                }
                row[x] = (a << 24 | r << 16 | g << 8 | b);
            }
        }
    }
}
