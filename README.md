# PokemonLibraryApp

This application is an iOS app that displays a list of Pokémon using the PokeAPI. It allows users to easily browse through each Pokémon's splash image, name, and number via a collection view.

## Features
- Pokémon Listing: Includes splash images, names, and numbers.
- Utilizes UIKit and RxSwift: For smooth asynchronous operations and UI updates.
- Clean Architecture: Offers excellent extendability and maintainability.
- Paging Feature: Automatically loads the data of the next Pokémon as the user scrolls.

## Tech Stack
- iOS (UIKit)
- RxSwift

## Data Source
This app uses PokeAPI as its data source. [PokeAPI](https://pokeapi.co/docs/v2) is a RESTful API that provides a comprehensive set of Pokémon data.

## Demo
### Collection & Paging
https://github.com/user-attachments/assets/edddaf97-cb21-471b-ac78-62a46b1c930b

### DetailView
https://github.com/user-attachments/assets/0b1b0543-6f24-41fd-a8a9-a96bb2f8c875

## Architecture
This app adopts Clean Architecture, clearly separating the UI, business logic, and data management layers.
<img width="1391" alt="image" src="https://github.com/user-attachments/assets/c22580a6-45bb-45c5-bd84-ac94db321f8e">
