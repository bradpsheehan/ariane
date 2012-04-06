module Ariane
  # Adds the ariane helper to controllers.
  module ControllerHelper

    # Internal: Sets a hash of cumb levels
    #
    # levels - Hash of crumb levels for actions
    #
    # Sets a hash of crumb levels for actions that require custom levels
    #
    # Returns nothing.
    def crumb_levels(levels)
      @crumb_levels = levels
    end

    # Internal: Sets the Ariane environment
    #
    # Sets the Ariane per request environment as well assigns the session hash.
    #
    # Returns Ariane.breadcrumb
    def ariane
      if !Ariane.request_env || Ariane.request != request.object_id
        Ariane.request     = request.object_id
        Ariane.request_env = request.env
        Ariane.session     = session if Ariane.use_session_stack
      end

      Ariane.breadcrumb
    end

    # Public: Controller helper method for auto creation of breadcrums.
    #
    # Automatically sets the breadcrumb based on controller and action names.
    #
    # Returns nothing
    def auto_set_breadcrumb
      
      ariane.add("Home", root_path, 1) if ariane.crumbs.empty? 
      
      if self.action_name == "index"
        name = self.controller_name.gsub(/_/, " ").capitalize
        level = get_level(2)
      else
        name = self.action_name.capitalize + " " + self.controller_name.singularize.gsub(/_/, " ").capitalize
        level = get_level(3)
      end

      ariane.add(name, request.fullpath, level)
    end


    private

    # Private: Helper method to retrieve a crumb level from the @crumb_levels hash 
    # if it exists.
    #
    # Returns level
    def get_level(default)
      return default unless @crumb_levels
      action = self.action_name.to_sym
      @crumb_levels[action] || default
    end
  end
end

ActionController::Base.send :include, Ariane::ControllerHelper
