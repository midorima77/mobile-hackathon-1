import 'package:flutter/material.dart';
import 'package:flutter_pokemon_app/models/pokemon_model.dart';
import 'package:http/http.dart' as http;

//states for the modal (inlined cubit)
enum _LoaderStates { init, loading, failed, loaded }

///
///  Show the dialog about the ability of the pokemon
///  referred by its `url`
///
void showPokemonDialog(BuildContext ctx, final String url) {
  //states goes here
  _LoaderStates state = _LoaderStates.init;
  PokemonModel? data;
  showDialog(
    context: ctx,
    builder: (context) => AlertDialog(
      content: SizedBox(
        height: 300,
        child: StatefulBuilder(
          builder: (context, setState) {
            //fire the async stuff here
            Future<void> loadData() async {
              state = _LoaderStates.loading;
              try {
                Uri endpoint = Uri.parse(url);
                http.Response response = await http.get(endpoint);

                if (response.statusCode == 200 /*ok*/) {
                  data = PokemonModel.fromJson(response.body);
                  setState(() {
                    state = _LoaderStates.loaded;
                  });
                } else {
                  throw Exception("Request failed");
                }
              } catch (e, st) {
                print(e);
                print(st);
                setState(() {
                  _LoaderStates.failed;
                });
              }
            }

            if (state == _LoaderStates.init) {
              loadData();
            }
            assert(state != _LoaderStates.init);
            switch (state) {
              case _LoaderStates.loading:
                return const Center(child: CircularProgressIndicator());
              case _LoaderStates.loaded:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text((data!.name).toUpperCase()),
                    const Text("ABILITIES",
                        // textAlign: TextAlign.start,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      height: 200,
                      width: 300.0,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data!.abilities.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text((data!.abilities[index].ability.name)
                                  .toString()),
                            );
                          }),
                    ),
                  ],
                );
              case _LoaderStates.failed:
                return const Text("something messed up");
            }
            return Container();
          },
        ),
      ),
    ),
  );
}
