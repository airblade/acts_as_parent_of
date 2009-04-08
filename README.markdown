ActsAsParentOf
==============

If you are on Rails 2.3 or above, use Rails' [nested attributes][http://guides.rubyonrails.org/2_3_release_notes.html#nested-attributes] feature.

If you are on Rails 2.2 or below, keep reading.

-----

This is lifted straight out of Advanced Rails Recipe 13, "Handle Multiple Models In One Form", by Ryan Bates.

For those using the recipe, you can save yourself some typing by adding the `acts_as_parent_of` declaration to your parent model.  For example:

    class Project < ActiveRecord::Base
      acts_as_parent_of :tasks
    end

You'll still need to write your views and controller as explained in the recipe.


Copyright (c) 2008 Andy Stewart (boss@airbladesoftware.com), released under the MIT license
