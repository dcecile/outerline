SRC = C:/Dev/playground/discover

QT_BIN = C:/Dev/lib/Qt/4.5.1/bin

CXX_FLAGS = \
        -IC:/Dev/lib/Qt/4.5.1/include \
        -IC:/Dev/lib/Qt/4.5.1/include/QtGui \
        -IC:/Dev/lib/Qt/4.5.1/include/QtNetwork \
        -IC:/Dev/lib/Qt/4.5.1/include/QtCore \
        "-IC:/Dev/lib/Bonjour SDK/Include" \
        -IC:/Dev/build/test \
        -DQT_DLL \
        -DQT_GUI_LIB \
        -DQT_NETWORK_LIB \
        -DQT_CORE_LIB \
        -DWIN32

LINK_FLAGS = \
        -Wl,--out-implib,libdiscover.dll.a -Wl,--major-image-version,0,--minor-image-version,0 C:/Dev/lib/Qt/4.5.1/lib/libQtGui4.a -limm32 -lwinmm C:/Dev/lib/Qt/4.5.1/lib/libQtNetwork4.a C:/Dev/lib/Qt/4.5.1/lib/libQtCore4.a -lws2_32 "C:/Dev/lib/Bonjour SDK/lib/win32/dnssd.lib"

GENERATED = ui_mainwindow.h mainwindow.moc

.PHONY: all

all: discover.exe

include noimplicit.make
# Alternative, use .SUFFIXES

EXE_FILE = discover.exe
SOURCE_FILES = main.cpp mainwindow.cpp
DEPEND_FILES = $(SOURCE_FILES:.cpp=.d)
OBJECT_FILES = $(SOURCE_FILES:.cpp=.o)
UI_FILES = mainwindow.ui
UIHEADER_FILES = $(UI_FILES:%.ui=ui_%.h)
MOC_FILES = mainwindow.moc

#ui_mainwindow.h: $(SRC)/mainwindow.ui
#mainwindow.moc: $(SRC)/mainwindow.h

$(DEPEND_FILES) $(OBJECT_FILES) $(UIHEADER_FILES) $(MOC_FILES) $(EXE_FILE): Makefile

$(EXE_FILE): $(OBJECT_FILES)
	g++ -o $@ $(OBJECT_FILES) $(LINK_FLAGS)

$(DEPEND_FILES):
	g++ -o $@ $(SRC)/$(@:.d=.cpp) $(CXX_FLAGS) -MP -MG -MM -MT $(@:.d=.o) -MT $@

-include $(DEPEND_FILES)

$(OBJECT_FILES):
	g++ -o $@ $(SRC)/$(@:.o=.cpp) -c $(CXX_FLAGS)

$(UIHEADER_FILES):
	$(QT_BIN)/uic -o $@ $<

$(MOC_FILES):
	$(QT_BIN)/moc -o $@ $< $(CXX_FLAGS)

.PHONY: clean

clean:
	del $(DEPEND_FILES) $(OBJECT_FILES) $(UIHEADER_FILES) $(MOC_FILES) $(EXE_FILE)

# TODO
# - auto precompiled header for project and system headers
# - build with manual pch disabled (redundancy / portability)
# - $(pwd | md5sum) /tmp (ramdisk) folder, rsync'd
# - O0 for developers
# - -j -l detection/suggestion
# - -pipe
# - dynamically linked object files
# - gold linker
# - log & graph build times vs. date/checkin
# - advanced unit test integration
# - unity build, or just all source files at once
