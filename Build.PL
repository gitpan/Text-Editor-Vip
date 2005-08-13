use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
	(
	module_name     => 'Text::Editor::Vip',
	license         => 'perl',
	requires => 
		{
		Data::TreeDumper    => '0.24',
		File::Slurp         => '0',
		Data::Hexdumper     => '0',
		Text::Diff          => '0',
		},
	)->create_build_script;
