use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
(
module_name     => 'Text::Editor::Vip',
dist_version_from => 'lib/Text/Editor/Vip.pm',
license         => 'perl',
)->create_build_script;
