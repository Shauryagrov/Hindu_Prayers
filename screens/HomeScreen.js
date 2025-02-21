import React from 'react';
import { View, FlatList, TouchableOpacity, StyleSheet, Text } from 'react-native';
import verses from '../data/verses';

export default function HomeScreen({ navigation }) {
  const renderVerseItem = ({ item, index }) => (
    <TouchableOpacity
      style={styles.verseCard}
      onPress={() => navigation.navigate('Verse', { verse: item, index: index })}
    >
      <Text style={styles.verseNumber}>Verse {index + 1}</Text>
      <Text style={styles.versePreview} numberOfLines={1}>
        {item.text}
      </Text>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={verses}
        renderItem={renderVerseItem}
        keyExtractor={(_, index) => index.toString()}
        contentContainerStyle={styles.listContainer}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff4e6',
  },
  listContainer: {
    padding: 16,
  },
  verseCard: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  verseNumber: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ff9933',
    marginBottom: 8,
  },
  versePreview: {
    fontSize: 16,
    color: '#333',
  },
}); 