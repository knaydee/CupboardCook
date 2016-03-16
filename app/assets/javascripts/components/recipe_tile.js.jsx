var RecipeTile = React.createClass({

  handleClick: function(event) {
    this.props.changeRecipeDetail(this.props.recipe);
  },

  addHeart: function(e) {
    e.preventDefault();
    var user_recipe = {
      heart: true,
      recipe_id: this.props.recipe.id
    };
    $.post('/user_recipes',{ user_recipe },
      function(data) {
        console.log(data);
      }.bind(this),
      'JSON'
    );
  },

  render: function(){
    var image = <img onClick={this.handleClick} src={this.props.recipe.image} />
    var pictureClass = "recipe-tile";
    if (this.props.recipe.image == null) {
      pictureClass = "recipe-tile no-image";
      image = "";
    }
    var missing;
    if (this.props.recipe.missing == 0 ) {
      missing = <i className="fa fa-thumbs-up fa-2x"></i>;
    } else {
      missing = <div className="missing-number"><p>-{this.props.recipe.missing}</p></div>;
    };
    return(
      <div className={pictureClass} >
        <div className="thumbnail">
            {image}
          <div className="caption">
          <h3 onClick={this.handleClick} >{this.props.recipe.title}</h3>
            <div className="icon-left">
              {missing}
            </div>
            <a onClick={this.addHeart}><i className="fa fa-heart fa-2x icon-right"></i></a>
          </div>
        </div>
      </div>
      );
  }
});
