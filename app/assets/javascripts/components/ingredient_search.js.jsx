var IngredientSearch = React.createClass({
  getInitialState() {
		return { ingredients: [],
             searchPath: this.props.searchPath};
	},

  resetSearch(){
    this.setState({ ingredients:[], query: '', autoFocus:'true' });
  },

	searchIngredients(event) {
    this.setState({query: event.target.value})
		if (event.target.value) {
			$.ajax({
		      url: this.props.searchPath+"?query="+event.target.value,

		      dataType: 'json',

		      success: function(data) {
		        this.setState({ingredients: data });
		      }.bind(this),

		      error: function(data) {
		      	this.setState({ingredients: [] });
		      }.bind(this)
		    });
		}
	},

	render() {
		return (
		<div className="top-section">
        <h1>Pantry</h1>
				<IngredientSearchBox searchPath={this.props.searchPath}
                             submitPath={this.searchIngredients}
                             query={this.state.query}/>
      <div className="row">
        <div className="col-xs-12 col-sm-8 col-sm-push-2 col-md-6 col-md-push-3">
        <Ingredients ingredients={this.state.ingredients}
                     addUserIngredient={this.props.addUserIngredient}
                     removeUserIngredient={this.props.removeUserIngredient}
                     resetSearch={this.resetSearch}
                     userIngredients={this.props.userIngredients} />
        </div>
     </div>
		</div>
			);

	}
});
