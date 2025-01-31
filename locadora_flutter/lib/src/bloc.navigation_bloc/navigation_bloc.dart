import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationEvents {
  DashboardClickedEvent,
  PublisherClickedEvent,
  RenterClickedEvent,
}

abstract class NavigationStates {}

class DashboardState extends NavigationStates {}

class PublisherState extends NavigationStates {}

class RenterState extends NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc() : super(DashboardState()) {
    on<NavigationEvents>((event, emit) {
      if (event == NavigationEvents.DashboardClickedEvent) {
        emit(DashboardState());
      } else if (event == NavigationEvents.PublisherClickedEvent) {
        emit(PublisherState());
      } else if (event == NavigationEvents.RenterClickedEvent) {
        emit(RenterState());
      }
    });
  }
}
