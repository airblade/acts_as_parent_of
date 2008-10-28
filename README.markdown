ActsAsParentOf
==============

This is lifted straight out of Advanced Rails Recipe 13, "Handle Multiple Models In One Form", by Ryan Bates.

For those using the recipe, you can save yourself some typing by adding the `acts_as_parent_of` declaration to your parent model.  For example:

    class Project < ActiveRecord::Base
      acts_as_parent_of :tasks
    end

You'll still need to write your views and controller as explained in the recipe.


To Do
=====

* Make `:validates_associated` optional.


Copyright (c) 2008 Andy Stewart (boss@airbladesoftware.com), released under the MIT license
