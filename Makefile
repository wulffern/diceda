
BUILD=build

clean:
	rm -rf ${BUILD}
	mkdir build

tclver=tcl8.6.10
tkver=tk8.6.10
prefix = ${HOME}/pro/eda/
${BUILD}/${tclver}:
	cd ${BUILD} && wget https://prdownloads.sourceforge.net/tcl/${tclver}-src.tar.gz
	cd ${BUILD} &&tar zxvf ${tclver}-src.tar.gz

${BUILD}/${tkver}:
	cd ${BUILD} && wget https://prdownloads.sourceforge.net/tcl/${tkver}-src.tar.gz
	cd ${BUILD} && tar zxvf ${tkver}-src.tar.gz

tcl: ${BUILD}/${tclver}
	cd ${BUILD} && cd ${tclver}/unix &&./configure --prefix=${prefix} && make && make install

tk: ${BUILD}/${tkver}
	cd ${BUILD} && cd ${tkver}/unix && ./configure --prefix=${prefix} --with-tcl=${prefix}/lib --with-x --x-includes=/usr/X11/include --x-libraries=/usr/lib/X11   && make && make install

${BUILD}/magic:
	cd ${BUILD} && git clone https://github.com/RTimothyEdwards/magic

cmagic:  ${BUILD}/magic
	cd ${BUILD} && perl -pe "s/-g/-g -Wno-error=implicit-function-declaration/ig" -i magic/configure
	cd ${BUILD} &&cd magic && git pull
	cd ${BUILD} &&cd magic && ./configure --prefix=${prefix} --with-tcl=${prefix}lib --with-tk=${prefix}lib --x-includes=/usr/include/X11 --x-libraries=/usr/lib/X11 && make
	cd ${BUILD} &&cd magic && make install


${BUILD}/xschem:
	cd ${BUILD} &&git clone https://github.com/StefanSchippers/xschem.git

cxschem:  ${BUILD}/xschem
	cd ${BUILD} &&cd xschem && git pull
	cd ${BUILD} &&cd xschem && ./configure --prefix=${prefix}
	cd ${BUILD} &&cd xschem && make
	cd ${BUILD} &&cd xschem && make install

${BUILD}/netgen:
	cd ${BUILD} &&git clone git@github.com:RTimothyEdwards/netgen.git

cnetgen:  ${BUILD}/netgen
	cd ${BUILD} &&perl -pe "s/-g/-g -Wno-error=implicit-function-declaration/ig" -i netgen/configure
	cd ${BUILD} &&cd netgen && ./configure --prefix ${prefix} --with-tcl=${prefix}lib --with-tk=${prefix}lib --x-includes=/usr/include/X11/ --x-libraries=/usr/lib/X11 && make && make install

${BUILD}/ngspice:
	cd ${BUILD} &&git clone https://git.code.sf.net/p/ngspice/ngspice ngspice

cic:
	cd ${HOME}/pro/cic/ciccreator && git pull && make
	cp ${HOME}/pro/cic/ciccreator/bin/linux/cic bin/cic
	cp ${HOME}/pro/cic/ciccreator/bin/linux/cic-gui bin/cic-gui

${BUILD}/iverilog:
	cd ${BUILD} &&git clone https://github.com/steveicarus/iverilog.git


civerilog:  ${BUILD}/iverilog
	cd ${BUILD} &&cd iverilog && git pull &&sh autoconf.sh && ./configure --prefix ${prefix} && make && make install

${BUILD}/yosys:
	cd ${BUILD} &&git clone https://github.com/YosysHQ/yosys.git


#cyosys:  ${BUILD}/yosys
#	cd ${BUILD} &&cd yosys && git pull &make config-gcc PREFIX=${prefix} && make PREFIX=${prefix} && make install
# TBD, fix prefix

# Pre-requisites
# brew install bison
# # fix bison paths
# Need to use gcc-11 or gcc-12 from homebrew to get openmp to work
cngspice: ngspice
#--enable-xspice --enable-cider --with-readline=yes --enable-openmp
	cd ${BUILD} &&cd ngspice && git pull && ./autogen.sh && ./configure \
	--prefix ${prefix} \
	--with-x \
	--x-includes=/usr/include/X11 \
	--x-libraries=/usr/lib/X11 \
	--enable-xspice  \
	--enable-openmp \
	--enable-pss \
	--enable-cider \
	--with-readline=yes \
	--disable-debug	&& CFLAGS="-g -m64 -O0 -Wall -Wno-unused-but-set-variable" LDFLAGS="-m64 -g" \
	&&  make -j8
	cd ${BUILD} &&cd ngspice &&  make install

all: tcl tk cmagic cxschem cngspice cive

replace:
	egrep -R "/home/wulff/pro/eda/" share -l | xargs -I{} perl -ibak -pe 's#/home/wulff/pro/eda/#\$$EDA_DIR/#ig' {}
	egrep -R "/home/wulff/pro/eda/" bin -l | xargs -I{} perl -ibak -pe 's#/home/wulff/pro/eda/#\$$EDA_DIR/#ig' {}
	egrep -R "/home/wulff/pro/eda/" lib -l | xargs -I{} perl -ibak -pe 's#/home/wulff/pro/eda/#\$$EDA_DIR/#ig' {}
