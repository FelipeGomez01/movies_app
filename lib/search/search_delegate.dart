import 'package:flutter/material.dart';
import 'package:movies_app/models/models.dart';
import 'package:movies_app/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class MovieSearchDelegate extends SearchDelegate
{
  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => 'Buscar Pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  Widget _emptyContainer()
  {
    return Container(
      child: const Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.black38,
          size: 130,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context)
  {
    if(query.isEmpty)
    {
      return _emptyContainer();
    }

    final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
    movieProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: movieProvider.suggestionStream,
      builder: ( _ , AsyncSnapshot<List<Movie>> snapshot)
      {
        if(!snapshot.hasData) return _emptyContainer();

        final movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: ( _ , int index) => _MovieItem(movies[index]),
        );
      },
    );
  }
}

class _MovieItem extends StatelessWidget
{
  final Movie movie;

  const _MovieItem(this.movie);

  @override
  Widget build(BuildContext context)
  {
    movie.heroId = 'search-${movie.id}';

    return Hero(
      tag: movie.heroId!,
      child: ListTile(
        leading: FadeInImage(
          placeholder: const AssetImage('assets/no-image.jpg'),
          image: NetworkImage(
            movie.fullPosterImg
          ),
          width: 50,
          fit: BoxFit.contain,
        ),
        title: Text(movie.originalTitle),
        onTap: (){
          Navigator.pushNamed(context, 'details', arguments: movie);
        },
      ),
    );
  }

}