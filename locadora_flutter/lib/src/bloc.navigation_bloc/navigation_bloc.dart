import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationEvents {
  DashboardClickedEvent,
  UserClickedEvent,
  PublisherClickedEvent,
  RenterClickedEvent,
  BookClickedEvent,
  RentClickedEvent,
}

abstract class NavigationStates {}

class DashboardState extends NavigationStates {}

class UserState extends NavigationStates {}

class PublisherState extends NavigationStates {}

class RenterState extends NavigationStates {}

class BookState extends NavigationStates {}

class RentState extends NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc() : super(DashboardState()) {
    on<NavigationEvents>((event, emit) {
      if (event == NavigationEvents.DashboardClickedEvent) {
        emit(DashboardState());
      } else if (event == NavigationEvents.PublisherClickedEvent) {
        emit(PublisherState());
      } else if (event == NavigationEvents.RenterClickedEvent) {
        emit(RenterState());
      } else if (event == NavigationEvents.BookClickedEvent) {
        emit(BookState());
      } else if (event == NavigationEvents.RentClickedEvent) {
        emit(RentState());
      } else if (event == NavigationEvents.UserClickedEvent) {
        emit(UserState());
      } 
    });
  }
}
