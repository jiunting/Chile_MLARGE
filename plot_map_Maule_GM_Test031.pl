#!/opt/local/bin/perl -w

#\rm .gmtdefaults4
`gmt defaults > gmt.conf`; #get original defaults
`gmt gmtset MAP_FRAME_TYPE fancy`;
`gmt gmtset FONT_HEADING 1 HEADER_FONT_SIZE 20 MAP_TITLE_OFFSET 0.0p`;
#gmt gmtset FONT_LABEL 1 LABEL_FONT_SIZE 10 LABEL_OFFSET 0.1i
#gmt gmtset FONT_ANNOT 1 ANNOT_FONT_SIZE 10 ANNOT_OFFSET 0.1i

#set stafile='/Users/timlin/Documents/Project/NASA/Cascadia/station_info.txt'  #All the Cascadia GPS stations
#$stafile='/Users/timlin/Documents/Project/Fakequake/Chile/data/station_info/Chile_GNSS.gflist';  #All the Chile GPS stations
$stafile='./Chile_GNSS.gflist';  #All the Chile GPS stations
#$stafile_exist='/Users/timlin/Documents/Project/NASA/LSTM_training/Chile/chile_GNSS/GMTout/Maule2010/exist_sta.txt';
$stafile_exist='./realEQ_Tcs_GMT/Maule2010/exist_sta.txt';

#$fault='/Users/timlin/Documents/Project/Fakequake/Chile/data/model_info/chile.fault';
$fault='./chile.fault';
#set grdlarge='/Users/timlin/Documents/Project/GMTplot/Grdfiles/topo15.grd' #input a large GRD file
#grdcut $grdlarge -G$grdfile -R$area
$grdfile='../Grdfiles/chile.grd';  #cut the $grdlarge and use this file
$grdgrad='./chile.gradient';
#gmt grdgradient $grdfile -G$grdgrad -A90 -Ne0.5

$SLAB='./chile.mshout';

$timeseries='./realEQ_Tcs_GMT/Maule2010/timeseries.txt';

#$rupt_path='/Volumes/Data2/Research/Cascadia_FQdata/ruptures'; #example rupture directory
#$wave_path='/Volumes/Data2/Research/Cascadia_FQdata/waveforms';
#$run_num='000159'; #so that the path of rupt file=rupt_file+'/'+'subduction.'+run_num+'.rupt'
#$run_num='000080'; #so that the path of rupt file=rupt_file+'/'+'subduction.'+run_num+'.rupt'
#$rupt_file="${rupt_path}/subduction.${run_num}.rupt";
#$wave_file="${wave_path}/subduction.${run_num}/_summary.subduction.${run_num}.txt";
#print "ruptfile=$rupt_file\n";
#print "wavefile=$wave_file\n";
#$scale_velo=0.4; #scale the psvelo for PGD
#$scale_velo=1.2; #scale the psvelo for PGD



$cmap='../Cpts/color_linear_slip.cpt';#colormap for slip

#set area='-77/-65/-45.0/-17'
#set area_L='-71.0/-31/-29.5/-14/8' #used by -JL
#$area='-78/-65.5/-45.0/-17';
$area='-77/-69.5/-43.0/-30';
#set area_L='-125.0/45/40/50/8' #used by -JL
$area_L='-71.0/-31/-15/-14/9.4'; #used by -JL
#$fileout="Cascadia_2_${run_num}";
#$EQID="000001";
##---Illapel---
#$evlo=-71.674;
#$evla=-31.573;
#$scale_velo=2.0; #scale for vector plot
#-------------

#---Maule-----
$evlo=-72.898;
$evla=-36.122;
#$scale_velo=1.8; #scale for vector plot
$scale_velo=3.0; #scale for vector plot

#make a base ps file, plot other things later
#`gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -Y2i -X1i -P -t70 -K  > Chile_rupts_base.ps`;
`gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Cgray_topo.cpt  -Y2i -X1i -P -t70 -K  > Chile_rupts_base.ps`;

`gmt grdsample $grdfile -I0.01d -R$area -T -Gtopo_PGA.grd`;  #re-sample the map.grd to the same region of PGA. "-T" is very important!
`gmt grdgradient topo_PGA.grd -Gtopo_PGA.grad -A90 -Ne0.3`;

for ($epo=0;$epo<=101;$epo++){
    #if ($epo>=20){
    #    next;
    #}
$epo=101;
$epo = sprintf "%03d",$epo;
$epo_sec = $epo*5+5;
print "epo=$epo\n";


$fileout="Chile_rupts.${epo}_new";

#set grdfile='crm.grd'
#set grdgrad='etopo1.grad'

#make a large white background
#`gmt psbasemap -R -J -Ba5f2.5g2.5WSen -O -K >> $fileout".ps"`;

#------instead of creating a new map every time, copy the base map--------
#`gmt grdimage $grdfile -I$grdgrad -JL$area_L -R$area -Ctopo.cpt -Y2i -X1i -P -t70 -K  > $fileout".ps"`;
`cp Chile_rupts_base.ps $fileout".ps"`;

#pscoast -R$area -JL$area_L -Df -W2 -N1  -S217/231/237 -Lf-128/40/45/200k+l"km"+f -P  -K > $fileout
#gmt pscoast -R$area -JL$area_L -Df -W2 -N1 -Td -Lg-128/40/40/200k+l"km"+f -O  -K >> $fileout


#pscoast -R$area -JL$area_L -Df -W2 -N1  -Lf-68/-43/-43/400k+l"km"+f -P -O -K >> $fileout
#`gmt psbasemap -R -J -Ba5f2.5g2.5WSen -O -K >> $fileout".ps"`;
`gmt psbasemap -R$area -JL$area_L -Ba5f2.5g2.5WSen -O -K >> $fileout".ps"`;  #use this instead for directly copy the base

    `gmt makecpt -A10 -Cmagma -T0.05/1/0.01 -I >PGA.cpt`;
    #-----------plot predicted PGA on map, once this is done uncomment these to plot PGA----------
    #$pred_shake = `ls /Users/timlin/TEST_MLARGE/GMTinp_Test028_GM_Pred/Test028.case0000002.epo${epo}.shake`; chomp($pred_shake);
    #$pred_shake = `ls /Users/timlin/TEST_MLARGE/GMTinp_Test030_GM_Pred/Test030.case0000002.epo${epo}.shake`; chomp($pred_shake);
    $pred_shake = `ls /Users/jtlin/TEST_MLARGE/GMTinp_Test031_GM_Pred/Test031.case0000002.epo${epo}.shake`; chomp($pred_shake);
    print "current shake file:$pred_shake\n";
    `cat $pred_shake | awk -F, 'NR>1{print(\$1,\$2,\$6)}' |gmt surface -R -T0 -I0.1d -Gshake.grd`;
    `gmt grdsample shake.grd -I0.01d -R -T -Gshake.grd`;
    `gmt grdimage shake.grd  -R -J -CPGA.cpt -Itopo_PGA.grad -O -K -t10 >> $fileout".ps"`; #grdimage in the whole area
    #------------------------------------------------
    
    
    #########Plot coast#########
    #+c-125/43 set the scale accurate at -125/43
    #-Lglon/lat
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
    `gmt pscoast -R$area -JL$area_L -Df -W0.5 -S204/229/255  -N1 -Tdg-73.5/-31.0+w0.5i+f1+l",,,N" -Lg-71.1/-42.2+c-72.0/-35+w200k+l"km"+f -O  -K >>$fileout".ps"`;
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    #############################
    
    
##########plot faults edge and slip#########
#$line=2;
#$line_slip=2;
#$nfaults=963;
#make slip_cpt
#$minslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | head -n 1`;
#$maxslip = `cat $rupt_file | awk 'NR>1{print(sqrt((\$9**2)+(\$10**2)))}' | sort -nk 1 | tail -n 1`;
#chomp($minslip);chomp($maxslip);
#print "minslip=$minslip\n";
#print "maxslip=$maxslip\n";

#$rang_slip=$maxslip-$minslip;
#$interv=$rang_slip/100;
#$maxslip_add=$maxslip+$interv*2;
#if ($maxslip<5){
#    $col_inc=1;
#}elsif($maxslip>=5 && $maxslip<10){
#    $col_inc=2;
#}elsif($maxslip>=10 && $maxslip<20){
#    $col_inc=4;
#}elsif($maxslip>=20 && $maxslip<40){
#    $col_inc=8;
#}elsif($maxslip>=40 && $maxslip<60){
#    $col_inc=15;
#}elsif($maxslip>=60){
#    $col_inc=20;
#}
#`gmt makecpt -C$cmap -T$minslip/$maxslip_add/0.5 -Z -V0 > slip.cpt`;


#for ($a1=0;$a1<$nfaults;$a1++){
#    #Get current line
#    print "$line\n";
#    `cat $SLAB | awk '(NR==$line){print(\$0)}' >slab.tmp`;
#    $line=$line+1;
#    `cat $rupt_file | awk '(NR==$line_slip){print(">-Z" (\$10**2+\$9**2)**0.5)}' >element.xy`;
#    $line_slip=$line_slip+1;
#    #Extracxt node coordinates
#    `awk '{print \$5,\$6}' slab.tmp >> element.xy`;
#    `awk '{print \$8,\$9}' slab.tmp >> element.xy`;
#    `awk '{print \$11,\$12}' slab.tmp >> element.xy`;
#    `awk '{print \$5,\$6}' slab.tmp >> element.xy`;
#    `gmt psxy element.xy -R -J -L -Cslip.cpt -O -K >>${fileout}.ps`; #Use GMT5 if this has issue (plot the triangle color)
#    #`gmt psxy element.xy -R -J -W0.01p,100/100/100 -O -K >> $fileout`;
#    `gmt psxy element.xy -R -J -W0.01p,200/200/200 -O -K >> ${fileout}.ps`; #Plot triangle boundary
#    if ($a1==99999){
#        last;
#    }
#}
##########################################


#------plot USGS finite fault---------
`gmt psxy Maule_cos5m.xy -W1.2p,255/0/255 -R -J -O -K >>$fileout".ps"`;

    
#-----------plot prediction fault on map----------
#$pred_fault = `ls /Users/timlin/TEST_MLARGE/Out3/fault_${epo}.txt`; chomp($pred_fault);
#$pred_fault = `ls /Users/timlin/TEST_MLARGE/GMTinp_Test028_GM_Pred/Test028.case0000002.epo${epo}.fault`; chomp($pred_fault);
#$pred_fault = `ls /Users/timlin/TEST_MLARGE/GMTinp_Test030_GM_Pred/Test030.case0000002.epo${epo}.fault`; chomp($pred_fault);
$pred_fault = `ls /Users/jtlin/TEST_MLARGE/GMTinp_Test031_GM_Pred/Test031.case0000002.epo${epo}.fault`; chomp($pred_fault);
print "current fault file:$pred_fault\n";
`cat $pred_fault | awk '{print(\$2,\$3)}' |gmt psxy -R -J -G0/0/255 -W0.3p,255/255/255 -Ss0.2c -t70 -O -K >>$fileout".ps"`;
# -------------------------------------------------

    
#-----plot time mark on the map-----
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "-75.6 -33.3 12 0 1 2 Time = ${epo_sec} s";
close(PSTEXT);



#makecpt -Cjet -T4/54/1 -Z  > depth.cpt
#`gmt makecpt -Cjet -T6/32/1 -Z >depth.cpt`;
#cat $fault | awk 'NR>1{print($2,$3,$4)}' |gmt psxy -R -J -G100/100/100  -Ss0.15 -Cdepth.cpt -O -K >>$fileout".ps"

#plot hypoloc
#$evlo=`cat $rupt_file | awk 'NR>1  && \$8!=0 && \$13==0{print(\$2)}'`;chomp($evlo);
#$evla=`cat $rupt_file | awk 'NR>1  && \$8!=0 && \$13==0{print(\$3)}'`;chomp($evla);
open(PSXY,"|gmt psxy -R -J  -Sa0.25i -W1p,255/0/0 -O -K >>$fileout'.ps'");
print PSXY "$evlo $evla\n";
close(PSXY);

#plot fault depth contour
`cat $fault | awk 'NR>1{print(\$2,\$3,\$4)}' | gmt pscontour -R -J  -A10,20,30+u" km"+r1 -C10,20,30 -W0.5p,50/50/50,-- -O -K >>$fileout".ps"`;

    
##plot stations color-coded with their PGD
##$minPGD = `cat $wave_file | awk 'NR>1{print(\$7)}' | sort -nk 1 | head -n 1`;chomp($minPGD);
#$maxPGD = `cat $wave_file | awk 'NR>1{print(\$7)}' | sort -nk 1 | tail -n 1`; chomp($maxPGD);
#$maxPGD_plot= $maxPGD + ($maxPGD/100)*2;
##print "min,max slip=$minPGD $maxPGD\n";
#`gmt makecpt -Cjet -T0/$maxPGD_plot/0.1 -Z -V0 > PGD.cpt`; #change the boundary manually
`cat $stafile | awk 'NR>1{print(\$2,\$3)}' |gmt psxy -R -J -G200/200/200 -W0.3p,0/0/0 -St0.5c -O -K >>$fileout".ps"`;
# ---plot timeseries vector---
$minZ = `cat $timeseries | awk 'NR>1{print(\$7)}' | sort -nk 1 | head -n 1`;chomp($minZ);
$maxZ = `cat $timeseries | awk 'NR>1{print(\$7)}' | sort -nk 1 | tail -n 1`; chomp($maxZ);
print "minZ,maxZ=$minZ $maxZ\n";
`gmt makecpt -Cseis -T-0.5/0.5/0.01 -Z -V0 > Z.cpt`; #change the boundary manually
`cat $timeseries | awk '(NR>1 && \$4==${epo_sec}){print(\$1,\$2,\$7)}' |gmt psxy -R -J -CZ.cpt -W0.3p,0/0/0 -St0.5c -O -K >>$fileout".ps"`; #station colorcoded by the Z value
    
    
    
    
`cat $timeseries | awk '\$4==${epo_sec}{print(\$1,\$2,\$5*${scale_velo},\$6*${scale_velo},0,0,0)}' | gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K  >>$fileout".ps"`;
    
    
    
#plot disp. scale
open(PSVELO,"|gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout'.ps'");
$tmpscale=2*${scale_velo};
print PSVELO "-76.5 -33.6 $tmpscale 0 0 0 0\n";
close(PSVELO);
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "-76.1 -33.9 12 0 1 2 2m";
close(PSTEXT);
    
#---plot colorscale---
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
`gmt psscale -Dx0.42i/4.7i/0.8i/0.12i -Ba0.5f0.25:"Z (m)": -CZ.cpt -E  -O -K >> $fileout".ps"`;
`gmt psscale -Dx0.42i/3.5i/0.8i/0.12i -Ba0.5f0.25:"PGA (g)": -CPGA.cpt -E  -O -K >> $fileout".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default

    
# ---plot Wphase solution---
open(PSMECA,"|gmt psmeca -C -Sc0.5/14/0 -G0/0/0 -R -J -O -K >> ${fileout}.ps");
print PSMECA "-72.898 -36.122 22.9  178 77 86  17 14 108   8.8  0 -71.5 -38.5 Maule (M8.8)\n";
close(PSMECA);
#-----------------------

    


#`cat $wave_file | awk 'NR>1{print(\$2,\$3,\$7)}' |gmt psxy -R -J -CPGD.cpt -W0.4p,0/0/0 -Sc0.24 -N -O -K >>$fileout".ps"`;
#
#
##plot disp. vectors
##` cat $wave_file | awk 'NR>1{print(\$2,\$3,\$5,\$4,0,0,0)}' | gmt psvelo -R -J -A0.05/0.35/0.15 -G255/195/0 -W0.15p,0/0/0 -Se0.16/0.95/0 -O -K -N >> $fileout".ps" `;
#` cat $wave_file | awk 'NR>1 && \$5<=-0.1 {print(\$2,\$3,\$5*${scale_velo},\$4*${scale_velo},0,0,0)}' | gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout".ps" `;
#
##plot disp. scale
#open(PSVELO,"|gmt psvelo -R -J -A0.033/0.25/0.06 -G50/50/50  -Se0.16/0.95/0 -O -K -N >> $fileout'.ps'");
#$tmpscale=5*${scale_velo};
#print PSVELO "-128.3 43.60 $tmpscale 0 0 0 0\n";
#close(PSVELO);
#open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
#print PSTEXT "-127.92 43.68 12 0 1 2 5m";
#close(PSTEXT);

#`gmt psscale -Dx0.5i/1.8i/1.5i/0.15i -Ba10f5:"depth(km)": -Cdepth.cpt -E  -O -K >> $fileout".ps"`;
#`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 0.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#`gmt psscale -Dx0.4i/2.9i/0.8i/0.12i -Ba15f7.5:"slip(m)": -Cslip.cpt -E  -O -K >> $fileout".ps"`;
#`gmt psscale -Dx0.4i/4.0i/0.8i/0.12i -Ba3f1.5:"PGD(m)": -CPGD.cpt -E  -O -K >> $fileout".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default gmtsetting





#########Plot coast#########
#+c-125/43 set the scale accurate at -125/43
#-Lglon/lat
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p`;
#`gmt pscoast -R$area -JL$area_L -Df -W0.5 -S204/229/255  -N1 -Tdg-73.5/-31.0+w0.5i+f1+l",,,N" -Lg-71.1/-42.2+c-72.0/-35+w200k+l"km"+f -O  -K >>$fileout".ps"`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
#############################




#####Plot Hemisphere map###############
#`psbasemap -Rd -JA$hypo[0]/$hypo[1]/50/1.6i -Ba20f10g10 -K -O -Y5.8i -X-0.8i >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
#`pscoast -Rd -JA$hypo[0]/$hypo[1]/50/1.6i -Ba20f10g10 -Dl -Gwhite -S200/200/200 -W0.8 -N1 -O -K >>$fileout`;
#`psbasemap -Rd -JA-71/-20/50/1.6i -Ba20f10g10 -K -O -Y5.8i -X-0.8i >>$fileout`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
`gmt psbasemap -Rd -JA-71/-20/50/1.81i -Ba20f10g10 -K -O -Y6.35i -X-0.55i >>${fileout}.ps`; #-Rg or -Rd is the shorthand for "global" g=0/360 d=-180/180
`gmt pscoast -Rd -JA -Ba30f15g15 -Dl -Gwhite -S200/200/200 -W0.5 -N1 -O -K >>${fileout}.ps`;
open(PSXY,"|gmt psxy -R -J -Sa0.35c -W0.8p,255/0/0 -O -K >>${fileout}.ps");
print PSXY "$evlo $evla\n";
close(PSXY);
####################



###### plot time series ########
#East/North/Up
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
`gmt psbasemap -R0/510/-40/-20 -JX2.5i/3.2i -Ba200f100g100:"Time(s)":/a5f2.5:"Lat.":WSen:."Surface deformation": -G255/255/255 -K -O -Y-1.65i -X4.95i >>${fileout}.ps`;
`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p FONT_TITLE 20p`; #the default gmtsetting
#`cat $timeseries | awk '(NR>1 && \$4<=500){print(\$4,\$2+\$5)}' |gmt psxy -R -J -G0/0/0 -Sc0.01c -W0.01p,0/0/200 -O -K >>${fileout}.ps`;
    
# get all uniq stations to group together
#`cat timeseries.txt | awk '(NR>1 && $4<500){print($3)}' | sort | uniq;`;
#`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    
@all_sta=`cat $timeseries | awk 'NR>1{print(\$3)}' | sort | uniq`;
chomp(@all_sta);
for ($a0=0;$a0<@all_sta;$a0++){
    $curr_sta = $all_sta[$a0];
    print "dealing with:$all_sta[$a0]\n";
    `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$5*0.5)}' |gmt psxy -R -J  -W0.8p,200/0/0 -O -K >>${fileout}.ps`;
    `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$6*0.5)}' |gmt psxy -R -J  -W0.8p,0/0/200 -O -K >>${fileout}.ps`;
    `cat $timeseries | awk '(NR>1 && \$4<=${epo_sec} && \$3=="$curr_sta"){print(\$4,\$2+\$7*0.5)}' |gmt psxy -R -J  -W0.8p,0/200/0 -O -K >>${fileout}.ps`;
        
}
#---plot scale---
open(PSXY,"|gmt psxy -R -J -W1.2p,0/0/0 -O -K >>${fileout}.ps");
print PSXY "420 -38 \n";
print PSXY "420 -39 \n";
close(PSXY);
open(PSTEXT,"|gmt pstext -R -J -O -K >>$fileout'.ps'");
print PSTEXT "450 -38.8 10 0 1 2 2m";
close(PSTEXT);

    
    
    
###### plot parameter predictions #######
    ###### plot parameter predictions #######
    
    #$pred_file='/Users/timlin/TEST_MLARGE/pred_parameters_Test030.txt';
    $pred_file='/Users/jtlin/TEST_MLARGE/pred_parameters_Test031.txt';
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    `gmt psbasemap -R0/510/0/150 -JX2.5i/0.6i -Ba200f100g100:"Time(s)":/a50f25:"Width":WSen -G255/255/255 -K -O -Y-4.52i >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1=="Maule2010" && \$2<=${epo_sec}){print(\$2,\$7)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 5.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    `gmt psbasemap -R0/510/0/600 -JX2.5i/0.6i -Ba200f100g100/a200f100:"Length":Wsen -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    `cat $pred_file | awk '(NR>1 && \$1=="Maule2010" && \$2<=${epo_sec}){print(\$2,\$6)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    
    `gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0p MAP_LABEL_OFFSET 2.5p FONT_LABEL 14p FONT_ANNOT_PRIMARY 12p FONT_TITLE 16p`;
    `gmt psbasemap -R0/510/-40/-30 -JX2.5i/0.6i -Ba200f100g100/a5f2.5:"Lat.":Wsen -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    #---plot real value---
    open(PSXY,"|gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps");
    print PSXY "0 -36.122\n";
    print PSXY "510 -36.122\n";
    close(PSXY);
    `cat $pred_file | awk '(NR>1 && \$1=="Maule2010" && \$2<=${epo_sec}){print(\$2,\$5)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;

    
    `gmt psbasemap -R0/510/-75/-70 -JX2.5i/0.6i -Ba200f100g100/a2f1:"Lon.":Wsen -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    #---plot real value---
    open(PSXY,"|gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps");
    print PSXY "0 -72.898\n";
    print PSXY "510 -72.898\n";
    close(PSXY);
    `cat $pred_file | awk '(NR>1 && \$1=="Maule2010" && \$2<=${epo_sec}){print(\$2,\$4)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;
    
    
    `gmt psbasemap -R0/510/7.0/9.2 -JX2.5i/0.6i -Ba200f100g100/a1f0.5:"Mw":Wsen:."Model prediction": -G255/255/255 -K -O -Y0.745i >>${fileout}.ps`;
    #---plot real value---
    open(PSXY,"|gmt psxy -R -J  -W2p,0/0/0,- -O -K >>${fileout}.ps");
    print PSXY "0 8.8\n";
    print PSXY "510 8.8\n";
    close(PSXY);
    #-----------------------
    `cat $pred_file | awk '(NR>1 && \$1=="Maule2010" && \$2<=${epo_sec}){print(\$2,\$3)}' | gmt psxy -R -J  -W2p,255/0/0 -O -K >>${fileout}.ps`;




open(PSXY,"|gmt psxy -R -J -O  >>$fileout'.ps'");
close(PSXY);

#`gmt ps2raster $fileout".ps" -Tf`; #convert file.ps to file.pdf
`gmt ps2raster $fileout".ps" -Tg`; #convert file.ps to file.png
#`gmt ps2raster $fileout".ps" -Tg`;
#`sips -s format png $fileout".pdf" --out $fileout".png"`;
#remove the .pdf,ps files
`rm $fileout".ps"`;
    
    
#`rm $fileout".pdf"`;
#`open $fileout".pdf"`;

`gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 5p MAP_LABEL_OFFSET 8p FONT_LABEL 16p FONT_ANNOT_PRIMARY 12p`; #the default
    
#    last;
} #end of epo loop

