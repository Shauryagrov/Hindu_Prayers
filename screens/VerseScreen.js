import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';

export default function VerseScreen({ route }) {
  const { verse, index } = route.params;

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.verseNumber}>Verse {index + 1}</Text>
        <Text style={styles.verseText}>{verse.text}</Text>
        <View style={styles.meaningContainer}>
          <Text style={styles.meaningTitle}>Meaning:</Text>
          <Text style={styles.meaningText}>{verse.meaning}</Text>
        </View>
        {verse.explanation && (
          <View style={styles.explanationContainer}>
            <Text style={styles.explanationTitle}>Simple Explanation:</Text>
            <Text style={styles.explanationText}>{verse.explanation}</Text>
          </View>
        )}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff4e6',
  },
  content: {
    padding: 20,
  },
  verseNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ff9933',
    marginBottom: 16,
  },
  verseText: {
    fontSize: 20,
    color: '#333',
    marginBottom: 24,
    lineHeight: 30,
  },
  meaningContainer: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  meaningTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ff9933',
    marginBottom: 8,
  },
  meaningText: {
    fontSize: 16,
    color: '#333',
    lineHeight: 24,
  },
  explanationContainer: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
  },
  explanationTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ff9933',
    marginBottom: 8,
  },
  explanationText: {
    fontSize: 16,
    color: '#333',
    lineHeight: 24,
  },
}); 