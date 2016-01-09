//
//  GameVariables.h
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-08.
//  Copyright 2011 167Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameVariables : NSObject {
    int numLevels;
    int currentLevel;
    int deathCount;
    int timeElapsed;
    
    double levelPackTopScores[5];
    double levelPackTopDeaths[5];
    double levelPackTopTimes[5];
    double nineLivesTopScore;
    double nineLivesTopLevelsFinished;
    double nineLivesTopTime;
    
    int careerScore;
    int careerTime;
    int careerDeaths;
    int totalTime;
    int totalDeaths;
    int careerStandardTime;
    int careerStandardDeaths;
    
    double practiceStars[52];
    BOOL inPracticeMode;
    
    BOOL nineLivesArray[52];
    BOOL nineLivesMode;
    int nineLivesLives;
    int nineLivesTime;
    int nineLivesScore;
    int nineLivesLevelsFinished;
    
    BOOL onStart;
    BOOL levelPacksFinished[5];
    BOOL levelsFinished[52];
    BOOL pauseMusic;
    BOOL pauseSounds;
    NSUserDefaults *saveState;
    int numVisits;
    int rated;
}

+(GameVariables*) sharedGameVariables;
-(int)getLevel;
-(void)setLevel:(int)toLevel;
-(int)getDeaths;
-(void)setDeaths:(int)deaths;
-(int)getTime;
-(void)setTime:(int)seconds;
-(BOOL)getOnStart;
-(void)setOnStart:(BOOL)start;
-(BOOL)getFinishedLevelPack:(int)level;
-(void)setFinishedLevelPack:(int)level;
-(BOOL)getFinishedLevel:(int)level;
-(void)setFinishedLevel:(int)level;
-(int)getNumLevels;

//Rate My App Code
-(void)addNumVisits;
-(int)getNumVisits;
-(int)getRated;
-(void)setRated;

//Practice Mode Code
-(int)getNumStars:(int)forLevel;
-(void)setNumStars:(int)forLevel withStars:(int)stars;
-(BOOL)getPractice;
-(void)setPracticeMode:(BOOL)practice;

//Career Mode Code
-(int)getCareerScore;
-(void)setCareerScore;
-(int)getCareerTime;
-(void)setCareerTime:(int)timeInSeconds;
-(int)getCareerDeaths;
-(void)setCareerDeaths:(int)deaths;
-(int)getTotalTime;
-(void)setTotalTime;
-(int)getTotalDeaths;
-(void)setTotalDeaths;
-(void)setCareerStandardTime:(int)timeInSeconds;
-(void)setCareerStandardDeaths:(int)deaths;
-(void)newLevelPack;

-(BOOL)getNineLivesMode;
-(void)setNineLivesMode:(BOOL)nineLives;
-(int)getNineLivesLives;
-(void)setNineLivesLives:(int)nineLives;
-(BOOL)getNineLivesLevel:(int)level;
-(void)setNineLivesLevel:(int)level isFinished:(BOOL)finished;
-(int)getRandomLevel;
-(int)getNineLivesScore;
-(void)setNineLivesScore:(int)score;
-(void)resetNineLives;
-(int)getNineLivesTime;
-(void)setNineLivesTime:(int)time;

-(int)getLevelPackTopScoreForPack:(int)levelPack;
-(void)setLevelPackTopScoreForPack:(int)levelPack withScore:(int)score;
-(int)getLevelPackTopTimeForPack:(int)levelPack;
-(void)setLevelPackTopTimeForPack:(int)levelPack withTime:(int)time;
-(int)getLevelPackTopDeathsForPack:(int)levelPack;
-(void)setLevelPackTopDeathsForPack:(int)levelPack withDeaths:(int)deaths;
-(int)getNineLivesTopScore;
-(void)setNineLivesTopScore:(int)score;
-(int)getNineLivesLevelsFinished;
-(int)getNineLivesTopLevelsFinished;
-(void)setNineLivesTopLevelsFinished;
-(int)getNineLivesTopTime;
-(void)setNineLivesTopTime;

-(void)saveLevels;
-(void)loadLevels;
-(void)saveLevelPacks;
-(void)loadLevelPacks;
-(void)saveStars;
-(void)loadStars;
-(void)saveHighScores;
-(void)loadHighScores;

-(BOOL)getPauseMusic;
-(void)setPauseMusic:(BOOL)pause;
-(BOOL)getPauseSound;
-(void)setPauseSound:(BOOL)pause;

@end
