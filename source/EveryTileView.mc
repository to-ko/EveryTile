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


    function deg2px(dgr)
    {
       var px = [0, 0];
       px[0] = Math.floor((((dgr[1] + 180.0d) * 45.5111111111111d)-mp.loni) * tileW).toNumber();
       px[1] = Math.floor(((1.0 - Math.ln(Math.tan(dgr[0]*0.0174532925199433d) + (1.0 / Math.cos(dgr[0]*0.0174532925199433d))) * 0.318309886183791d) *8192-mp.lati)*tileH).toNumber();
       return px;
    }

    function pxdist(dgr1,dgr2)
    {
       if (  (   ((dgr1[1]-dgr2[1]) * 45.5111111111111d * tileW ).abs().toNumber()>1 ) ||
             (   ( (- Math.ln(Math.tan(dgr1[0]*0.0174532925199433d) + (1.0 / Math.cos(dgr1[0]*0.0174532925199433d)))
                    + Math.ln(Math.tan(dgr2[0]*0.0174532925199433d) + (1.0 / Math.cos(dgr2[0]*0.0174532925199433d))) ) * 0.318309886183791d *8192*tileH
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


    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc)
    {
       dx = dc.getWidth();
       dy = dc.getHeight();

       tx = [0, dx>>3, 3*dx>>3, 5*dx>>3, dx-dx>>3, dx+1];
       ty = [40, 40+dx>>3, 40+3*dx>>3, 40+5*dx>>3, 40+7*dx>>3, dy+1];
       tileW = dx>>2;
       tileH = dx>>2;

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
          if (info.elapsedTime < 100)
          {
             //case when new activity was started, but the old view is still alive
             initialized=false;
             return;
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
                pt.set(0,dgr);
                mp.setTiles(cpt.p,cpt.l);
                cpt.save();
                mp.save();
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


    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        fgbgCol(dc,Gfx.COLOR_WHITE,Gfx.COLOR_BLACK);

        //this data field works only in 1-datafield layout
        if((dx>=200) & (dy>=265))
        {
           var mx = dx>>1;
           var my = dy>>1;
           var lx=0;
           var ly=0;
           var i=0;


           // header line
           dc.setClip(tx[0],0,dx,ty[0]);

           dc.drawText(mx, ty[0]/4, Gfx.FONT_MEDIUM,
              mp.newTiles.format("%i")+","+mp.newTilesR.format("%i")+",["+(mp.loni-mp.hloni).format("%i")+"/"+(mp.lati-mp.hlati).format("%i")+"]",
              Gfx.TEXT_JUSTIFY_CENTER);

           dc.setClip(tx[0],ty[0],dx,dy-ty[0]);
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
           fgbgCol(dc,Gfx.COLOR_LT_GRAY,Gfx.COLOR_BLACK);

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
            dc.drawText(dc.getWidth()/2,5,Gfx.FONT_MEDIUM,"needs whole disp.",Gfx.TEXT_JUSTIFY_CENTER);
         }

    }

}
