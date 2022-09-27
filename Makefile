
tclver=tcl8.6.10
tkver=tk8.6.10
prefix = ${HOME}/pro/eda/
${tclver}:
	wget https://prdownloads.sourceforge.net/tcl/${tclver}-src.tar.gz
	tar zxvf ${tclver}-src.tar.gz

${tkver}:
	wget https://prdownloads.sourceforge.net/tcl/${tkver}-src.tar.gz
	tar zxvf ${tkver}-src.tar.gz

tcl: ${tclver}
	cd ${tclver}/unix &&./configure --prefix=${prefix}/tcl-tk && make && sudo make install

tk: ${tkver}
	cd ${tkver}/unix && ./configure --prefix=${prefix}/tcl-tk --with-tcl=${prefix}/tcl-tk/lib --with-x --x-includes=/usr/X11/include --x-libraries=/usr/lib/X11   && make && sudo make install

magic:
	git clone https://github.com/RTimothyEdwards/magic

cmagic: magic
	perl -pe "s/-g/-g -Wno-error=implicit-function-declaration/ig" -i magic/configure
	cd magic && ./configure --prefix=${prefix}tcl-tk --with-tcl=${prefix}tcl-tk/lib --with-tk=${prefix}tcl-tk/lib --x-includes=/usr/include/X11 --x-libraries=/usr/lib/X11 && make
	cd magic && make install


xschem:
	git clone https://github.com/StefanSchippers/xschem.git

cxschem: xschem
	cd xschem && ./configure --prefix=${prefix}
	cd xschem && make
	cd xschem && make install

netgen:
	git clone git@github.com:RTimothyEdwards/netgen.git

cnetgen: netgen
	perl -pe "s/-g/-g -Wno-error=implicit-function-declaration/ig" -i netgen/configure
	cd netgen && ./configure --prefix ${prefix} --with-tcl=${prefix}tcl-tk/lib --with-tk=${prefix}tcl-tk/lib --x-includes=/usr/include/X11/ --x-libraries=/usr/lib/X11 && make && make install

ngspice:
	git clone https://git.code.sf.net/p/ngspice/ngspice ngspice

cic:
	cd ${HOME}/pro/cic/ciccreator && git pull && make
	cp ${HOME}/pro/cic/ciccreator/bin/linux/cic bin/cic
	cp ${HOME}/pro/cic/ciccreator/bin/linux/cic-gui bin/cic-gui

iverilog:
	git clone https://github.com/steveicarus/iverilog.git


civerilog: iverilog
	cd iverilog && sh autoconf.sh && ./configure --prefix ${prefix} && make && make install

yosys:
	git clone https://github.com/YosysHQ/yosys.git


cyosys: yosys
	cd yosys && make config-gcc PREFIX=${prefix} && make PREFIX=${prefix} && make install
# TBD

# Pre-requisites
# brew install bison
# # fix bison paths
# Need to use gcc-11 or gcc-12 from homebrew to get openmp to work
cngspice: ngspice
#--enable-xspice --enable-cider --with-readline=yes --enable-openmp
	cd ngspice && ./autogen.sh && ./configure \
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
	cd ngspice &&  make install

all: tcl tk cmagic cxschem cngspice
