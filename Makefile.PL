# When you compiled GOODS using makefile.freebsd, use this.
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	=> 'Pogo',
    'VERSION_FROM' => 'Pogo.pm', # finds $VERSION
    'CC'	=> 'g++',
    'LD'	=> '$(CC)',
    'LDDLFLAGS' => '-shared -L/usr/local/lib',
    'LIBS'	=> '-lg++ -lstdc++ -lgcc -L/usr/local/goods/lib -lclient',
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '-I/usr/local/goods/inc',
    'XSPROTOARG'	=> '-noprototypes',
    'OBJECT'	=> 'Pogo.o pogomain.o pogogcls.o pogocall.o nstring.o',
);
