class User < ActiveRecord::Base
  validates :email, :username, :uid, :provider, presence: true
  has_many :user_ingredients
  has_many :ingredients, through: :user_ingredients
  has_many :user_recipes
  has_many :recipes, through: :user_recipes

  def self.find_or_create_from_omniauth(auth_hash)
    user = self.find_by(uid: auth_hash["uid"], provider: auth_hash["provider"])
    if !user.nil?
      return user
    elsif auth_hash["provider"] == "google"
      user            = User.new
      user.uid        = auth_hash["uid"]
      user.provider   = auth_hash["provider"]
      user.username   = auth_hash["info"]["name"]
      user.email      = auth_hash["info"]["email"]
      user.image      = auth_hash["info"]["image"]
      if user.save
        return user
      else
        return nil
      end
    end
  end

  def pantry_names
    pantry_names = self.ingredients.map do |i|
      i = i.name
    end
    return pantry_names
  end

  #returns a hash with the recipe id key mapping to the number of ingredients you have for the recipe
  def find_recipe_hash(missing)
    pantry_names = self.pantry_names
    recipe_hash = Recipe.select("recipes.id").joins(:ingredients).where(ingredients: {name: pantry_names}).group("recipes.id").having('COUNT(*) >= recipes.ingredient_count - ?', missing).count
    return recipe_hash
  end

  # def find_recipes(missing = 0)
  #   recipe_hash = self.find_recipe_hash(missing)
  #   # recipe_id_array = recipe_hash.keys
  #   user_recipes = Recipe.where(id: recipe_hash.keys)
  #   return user_recipes
  # end

  def pantry_items_as_json
    self.user_ingredients.eager_load(:ingredient).as_json(:except => [:create_at, :updated_at],
                                                          :include => {:ingredient => {:only => :name}} )
  end

  def find_recipes_as_json(search_options = {missing: 0, heart: false, query:"*"})
    recipe_hash = self.find_recipe_hash(search_options[:missing])
    heart_array = self.recipes.pluck(:id)
    heart_hash = {}
    heart_array.each do |heart|
      heart_hash[heart] = true
    end
    if search_options[:heart]
      recipe_id_array = heart_array
    else
      recipe_id_array = recipe_hash.keys
    end
    user_recipes = Recipe.search_recipes(recipe_id_array, search_options[:query])
    results = user_recipes.as_json(:except => [:create_at, :updated_at],
                                               :include => {:ingredients => {:only => [:name, :id]}})
    results.each do |recipe|
      if recipe_hash[recipe["id"]]
        missing = recipe["ingredient_count"] - recipe_hash[recipe["id"]]
      else
        missing = recipe["ingredient_count"]
      end
      if heart_hash[recipe["id"]]
        heart = true
      else
        heart = false
      end
      recipe["missing"] = missing
      recipe["heart"] = heart
    end
  end
end
