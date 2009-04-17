Fixed Point Math
================

Fixed Point Math is a very simple ActiveRecord extension that handles the conversion of float
values to fixed point integer values. It automatically sets up setter and getter methods that
convert between the fixed point value (the setter) and the float value (the getter).

Install
=======

The easiest way to install this plugin is to do:

  ./script/plugin install git://github.com/spidah/fixed_point_math.git

Example
=======

In your ActiveRecord model you just need to add:

    fixed_point_number :column1, :column2

You can also use a plain version that returns integer values instead of float values:

    fixed_point_number_integer :column1, :column2


Copyright (c) 2009 David Hayward, released under the MIT license
