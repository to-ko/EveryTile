//! Copyright (C) 2018 Tomasz Korzec <tom@shmo.de>
//!
//! This program is free software: you can redistribute it and/or modify it
//! under the terms of the GNU General Public License as published by the Free
//! Software Foundation, either version 3 of the License, or (at your option)
//! any later version.
//!
//! This program is distributed in the hope that it will be useful, but WITHOUT
//! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//! FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//! more details.
//!
//! You should have received a copy of the GNU General Public Lice

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.Activity as Act;
using Toybox.Application.Storage;

class EveryTileView extends Ui.DataField {
    hidden var tileW = 50;
    hidden var tileH = 50;
    hidden var initialized = false;

    hidden var pt;          // fine path
    hidden var cpt;         // coarse path

    hidden var tx = new[6]; // coordinates of tiles on the screen
    hidden var ty = new[6];
    hidden var dx = 0;      // screen size
    hidden var dy = 0;
    hidden var heading = 0.0;
    hidden var mp;          // main map object
    hidden var landsc=false;
    hidden var mx;
    hidden var my;
    hidden var singleDF = true;


    function deg2px(dgr)
    {
       var px = [0, 0];
       px[0] = Math.floor((((dgr[1] + 180.0) * 45.5111111111111)-mp.loni) * tileW).toNumber();
       px[1] = Math.floor(((1.0 - Math.ln(Math.tan(dgr[0]*0.0174532925199433) + (1.0 / Math.cos(dgr[0]*0.0174532925199433))) * 0.318309886183791) *8192-mp.lati)*tileH).toNumber();
       return px;
    }

    function pxdist(dgr1,dgr2)
    {
       if (  (   ((dgr1[1]-dgr2[1]) * 45.5111111111111 * tileW ).abs().toNumber()>1 ) ||
             (   ( (- Math.ln(Math.tan(dgr1[0]*0.0174532925199433) + (1.0 / Math.cos(dgr1[0]*0.0174532925199433)))
                    + Math.ln(Math.tan(dgr2[0]*0.0174532925199433) + (1.0 / Math.cos(dgr2[0]*0.0174532925199433))) ) * 0.318309886183791 *8192*tileH
                 ).abs().toNumber()>1))
       {
          return true;
       }else
       {
          return false;
       }
    }


    function initialize()
    {
       DataField.initialize();
       mp = new map();
       pt = new path(50,mp.hlon,mp.hlat);
       cpt= new path(200,mp.hlon,mp.hlat);

       initialized=false;

       var inf = Act.getActivityInfo();
       if( (inf!=null) && (inf.elapsedTime > 10000) )
       {
          // attempt to continue activity
          mp.newTiles=Storage.getValue("newTiles");
          mp.newTilesR=Storage.getValue("newTilesR");
          if( cpt.load() && (mp.newTiles!=null) && (mp.newTilesR!=null) )
          {
             pt.set(0,cpt.getDeg(null));
             mp.setMap(pt.p[0],pt.p[1]);
             initialized = true;
          }else
          {
             mp.newTiles = 0;
             mp.newTilesR = 0;
          }
       }
    }

    function onTimerReset()
    {
       initialized=false;
    }


    (:ed520)
    function onLayout(dc)
    {
       // hard coded for devices with 200x265
       dx=dc.getWidth();
       dy=dc.getHeight();
       mx = dx>>1;
       my = dy>>1;
       if (dx != 200 || dy != 265)
       {
          singleDF = false;
       }else
       {
          singleDF = true;
       }
       tx=[ 0, 25,  75, 125, 175, 201];
       ty=[40, 65, 115, 165, 215, 266];
       tileW=50;
       tileH=50;

       return true;
    }

    (:ed530)
    function onLayout(dc)
    {
       dx=dc.getWidth();
       dy=dc.getHeight();
       mx = dx>>1;
       my = dy>>1;
       if(dx>dy)
       {
          // hard coded for devices with 322x246
          if (dx != 322 || dy != 246)
          {
             singleDF = false;
          }else
          {
             singleDF = true;
          }
          tx=[ 72, 122,  172, 222, 272, 323];
          ty=[0, 48, 98, 148, 198, 247];
          tileW=50;
          tileH=50;
          landsc = true;
       }else
       {
          // hard coded for devices with 246x322
          if (dx != 246 || dy != 322)
          {
             singleDF = false;
          }else
          {
             singleDF = true;
          }
          tx=[ 0, 48,  98, 148, 198, 247];
          ty=[72, 122, 172, 222, 272, 323];
          tileW=50;
          tileH=50;
          landsc = false;
       }
       return true;
    }


    (:ed1000)
    function onLayout(dc)
    {
       dx=dc.getWidth();
       dy=dc.getHeight();
       mx = dx>>1;
       my = dy>>1;
       if(dx>dy)
       {
          // hard coded for devices with 400x240
          if (dx != 400 || dy != 240)
          {
             singleDF = false;
          }else
          {
             singleDF = true;
          }
          tx=[ 100, 160,  220, 280, 340, 401];
          ty=[0, 30, 90, 150, 210, 241];
          tileW=60;
          tileH=60;
          landsc = true;
       }else
       {
          // hard coded for devices with 240x400
          if (dx != 240 || dy != 400)
          {
             singleDF = false;
          }else
          {
             singleDF = true;
          }
          tx=[ 0, 30,  90, 150, 210, 241];
          ty=[100, 160, 220, 280, 340, 401];
          tileW=60;
          tileH=60;
          landsc = false;
       }
       return true;
    }

    (:ed1030)
    function onLayout(dc)
    {
       dx=dc.getWidth();
       dy=dc.getHeight();
       mx = dx>>1;
       my = dy>>1;
       if(dx>dy)
       {
          // hard coded for devices with 470x282
          if (dx != 470 || dy != 282)
          {
             singleDF = false;
          }else
          {
             singleDF = true;
          }
          tx=[ 110, 182,  254, 326, 398, 471];
          ty=[ 0, 33,  105, 177, 249, 283];
          tileW=72;
          tileH=72;
       }else
       {
          // hard coded for devices with 282x470
          if (dx != 282 || dy != 470)
          {
             singleDF = false;
          }else
          {
             singleDF = true;
          }
          tx=[ 0, 33,  105, 177, 249, 283];
          ty=[110, 182, 254, 326, 398, 471];
          tileW=72;
          tileH=72;
          landsc = false;
       }

       return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info)
    {
       if( info != null)
       {
          heading = info.currentHeading;
          if(heading==null)
          {
             heading = 0.0;
          }

          if (info.currentLocation != null)
          {
             var ddgr = info.currentLocation.toDegrees();
             var dgr = [ddgr[0].toFloat(), ddgr[1].toFloat()];
             var i= 0;
             if(!initialized)
             {
                pt.set(0,dgr);
                //cpt.set(0,dgr);
                cpt.l=-1;
                mp.newTiles = 0;
                mp.newTilesR= 0;
                initialized=true;
                mp.loni = 16385; // to force a map update
             }

             if( pxdist(dgr,pt.getDeg(null)) )
             {
                pt.add(dgr);
             }
             if( mp.setMap(dgr[1],dgr[0]) )
             {
                cpt.add(dgr);
                mp.setTiles(cpt.p,cpt.l);
                cpt.save();
                //Storage.setValue eats mem like crazy, free some up before saving...
                cpt.p = null;
                pt.p = null;
                mp.save();
                cpt.load();
                pt.p = new[100];
                pt.set(0,dgr);
             }
          }
       }
    }


    function fgbgCol(dc, col1, col2)
    {
       if(getBackgroundColor()==Gfx.COLOR_BLACK)
       {
          dc.setColor(col1,Gfx.COLOR_BLACK);
       }else
       {
          dc.setColor(col2,Gfx.COLOR_WHITE);
       }
    }


    function setCol(dc,v)
    {
      if(v==0)
      {
         dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_DK_RED);
      }
      if(v==1)
      {
         dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
      }
      if(v==2)
      {
         dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
      }
    }


    function plotArrow(dc,x,y)
    {
       // rotate and translate
       var c =  Math.cos(heading);
       var s = -Math.sin(heading);
       var x2= Math.round( c*(-6) +s*(20.0)).toNumber() + x;
       var y2= Math.round(-s*(-6) +c*(20.0)).toNumber() + y;
       var x3= Math.round(        +s*(15.0)).toNumber() + x;
       var y3= Math.round(        +c*(15.0)).toNumber() + y;
       var x4= Math.round( c*( 6) +s*(20.0)).toNumber() + x;
       var y4= Math.round(-s*( 6) +c*(20.0)).toNumber() + y;

       fgbgCol(dc,Gfx.COLOR_DK_BLUE,Gfx.COLOR_BLUE);
       dc.fillPolygon([[x,y],[x2,y2],[x3,y3],[x4,y4],[x,y]]);
       fgbgCol(dc,Gfx.COLOR_BLUE,Gfx.COLOR_DK_BLUE);
       dc.drawLine(x,y,x2,y2);
       dc.drawLine(x2,y2,x3,y3);
       dc.drawLine(x3,y3,x4,y4);
       dc.drawLine(x4,y4,x,y);
    }


    (:header)
    function header(dc)
    {
       dc.setClip(tx[0],0,dx,ty[0]);

       dc.drawText(mx, ty[0]/4, Gfx.FONT_SMALL,
              "new: "+mp.newTiles.format("%i")+", tot: "+mp.newTilesR.format("%i")+", pos: ["+(mp.loni-mp.hloni).format("%i")+"/"+(mp.lati-mp.hlati).format("%i")+"]",
              Gfx.TEXT_JUSTIFY_CENTER);

       dc.setClip(tx[0],ty[0],dx,dy-ty[0]);
    }

    (:headerV)
    function header(dc)
    {
       if(landsc==true)
       {
           dc.setClip(0,0,tx[0],dy);
           dc.drawText(tx[0]/2, dy/4-16, Gfx.FONT_TINY, "new tiles",Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, dy/4, Gfx.FONT_MEDIUM,
              mp.newTiles.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, dy/2-16, Gfx.FONT_TINY, "tiles crossed",Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, dy/2, Gfx.FONT_MEDIUM,
              mp.newTilesR.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, 3*dy/4-16, Gfx.FONT_TINY, "current pos.",Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2,3*dy/4, Gfx.FONT_MEDIUM,
             "["+(mp.loni-mp.hloni).format("%i")+"/"+(mp.lati-mp.hlati).format("%i")+"]",Gfx.TEXT_JUSTIFY_CENTER);

           dc.setClip(tx[0],0,dx-tx[0],dy);
        }else
        {
           dc.setClip(tx[0],0,dx,ty[0]);

           dc.drawText(mx, 1, Gfx.FONT_MEDIUM,
              "new tiles: "+mp.newTiles.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(mx, ty[0]/3, Gfx.FONT_MEDIUM,
              "tiles crossed: "+mp.newTilesR.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(mx, 2*ty[0]/3, Gfx.FONT_MEDIUM,
              "current pos.: ["+(mp.loni-mp.hloni).format("%i")+"/"+(mp.lati-mp.hlati).format("%i")+"]",
              Gfx.TEXT_JUSTIFY_CENTER);

           dc.setClip(tx[0],ty[0],dx,dy-ty[0]);
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        fgbgCol(dc,Gfx.COLOR_WHITE,Gfx.COLOR_BLACK);

        //this data field works only in 1-datafield layout
        if(singleDF==true)
        {
           var lx=0;
           var ly=0;
           var i=0;

           header(dc);

           // draw 5x5 tiles
           for(ly=0;ly<5;ly++)
           {
              for(lx=0;lx<5;lx++)
              {
                 setCol(dc,mp.ltiles[lx+5*ly]);
                 dc.fillRectangle(tx[lx], ty[ly], tx[lx+1]-tx[lx]-1, ty[ly+1]-ty[ly]-1);
              }
           }

           var px = deg2px([mp.clat,mp.clon]);
           plotArrow(dc,px[0]+tx[2],px[1]+ty[2]);

           // fine grained path
           dc.setPenWidth(2);
           fgbgCol(dc,Gfx.COLOR_DK_GRAY,Gfx.COLOR_BLACK);

           lx=px[0];
           ly=px[1];
           for(i=pt.l-1; i>=0; i--)
           {
              px = deg2px(pt.getDeg(i));
              dc.drawLine(lx+tx[2],ly+ty[2],px[0]+tx[2],px[1]+ty[2]);
              lx=px[0];
              ly=px[1];
           }


           // coarse grained path
           fgbgCol(dc,Gfx.COLOR_DK_GRAY,Gfx.COLOR_DK_GRAY);

           for(i=cpt.l; i>=0; i--)
           {
              px = deg2px(cpt.getDeg(i));
              dc.drawLine(lx+tx[2],ly+ty[2],px[0]+tx[2],px[1]+ty[2]);
              lx=px[0];
              ly=px[1];
           }
           dc.setPenWidth(1);
         }else
         {
            dc.setClip(0,0,dx,dy);
            dc.drawText(dx/2,5,Gfx.FONT_MEDIUM,Ui.loadResource(Rez.Strings.wholeDisp),Gfx.TEXT_JUSTIFY_CENTER);
         }

    }

}
