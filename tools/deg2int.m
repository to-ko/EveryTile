function [xi,yi] = deg2int(x,y)
  zoom=14;
  lat_rad = y*pi/180;
  n = 2.0^zoom;
  xi = floor((x + 180.0) / 360.0 * n);
  yi = floor((1.0 - log(tan(lat_rad) + (1 / cos(lat_rad))) / pi) / 2.0 * n);
end

