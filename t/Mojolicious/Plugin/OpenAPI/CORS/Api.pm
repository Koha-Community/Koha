package t::Mojolicious::Plugin::OpenAPI::CORS::Api;
use Mojo::Base 'Mojolicious::Controller';

sub add_pet {
  my $c = shift->openapi->valid_input or return;
  $c->render(openapi => $c->validation->params->to_hash, status => 200);
}
sub cors_list_pets {
  my $c = shift->openapi->valid_input or return;
  $c->render(openapi => {pet1 => 'George', pet2 => 'Georgina'}, status => 200);
}
sub cors_list_humans {
  my $c = shift->openapi->valid_input or return;
  $c->render(openapi => {pet1 => 'George', pet2 => 'Georgina'}, status => 200);
}
sub cors_delete_pets {
  my $c = shift->openapi->valid_input or return;
  $c->render(openapi => {delete => 'ok'}, status => 204);
}

1;
