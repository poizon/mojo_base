package App::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';


sub show_index {
    my $s = shift;
    return $s->render(template => 'index');
}

1;
