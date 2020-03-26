#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <Godot.hpp>
#include <Node2D.hpp>

namespace godot {

class GDExample : public Node2D {
    GODOT_CLASS(GDExample, Node2D)

public:
    static void _register_methods();

    GDExample();
    ~GDExample();

	void foo();

    void _init(); // our initializer called by Godot

    void _process(float delta);
};

}

#endif
