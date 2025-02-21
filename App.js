import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import HomeScreen from './screens/HomeScreen';
import VerseScreen from './screens/VerseScreen';

const Stack = createStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="Home" 
          component={HomeScreen}
          options={{
            title: 'Hanuman Chalisa for Kids',
            headerStyle: {
              backgroundColor: '#ff9933',
            },
            headerTintColor: '#fff',
          }}
        />
        <Stack.Screen 
          name="Verse" 
          component={VerseScreen}
          options={{
            title: 'Learn Verse',
            headerStyle: {
              backgroundColor: '#ff9933',
            },
            headerTintColor: '#fff',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
} 