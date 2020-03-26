#include "gdexample.h"

using namespace godot;

void GDExample::_register_methods() {
    register_method("_process", &GDExample::_process);
    register_method("foo", &GDExample::foo);
}

GDExample::GDExample() {
}

GDExample::~GDExample() {
}

void GDExample::_init() {
}

void GDExample::foo() {
}

void GDExample::_process(float delta) { }
