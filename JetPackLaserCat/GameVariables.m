//
//  GameVariables.m
//  JetPackLaserCat
//
//  Created by Noel Feliciano on 11-08-08.
//  Copyright 2011 167Games. All rights reserved.
//

#import "GameVariables.h"

@implementation GameVariables
static GameVariables* _sharedGameVariables = nil;

+(GameVariables*)sharedGameVariables {
    @synchronized([GameVariables class]) {
        if (!_sharedGameVariables)
            _sharedGameVariables = [[self alloc] init];
        
        return _sharedGameVariables;
    }
}

+(id)alloc {
    @synchronized([GameVariables class]) {
        NSAssert(_sharedGameVariables == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedGameVariables = [super alloc];
        return _sharedGameVariables;
    }
    return nil;
}

-(void) dealloc {
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        saveState = [NSUserDefaults standardUserDefaults];
        numLevels = 30;
        for (int i = 0; i < 4; i++) {
            levelsFinished[i] = NO;
        }
    }
    
    return self;
}



-(int)getLevel {
    return currentLevel;
}

-(void)setLevel:(int)toLevel {
    currentLevel = toLevel;
}

-(int)getDeaths {
    return deathCount;
}

-(void)setDeaths:(int)deaths {
    deathCount = deaths;
}

-(BOOL)getOnStart {
    onStart = [saveState boolForKey:@"onStart"];
    return onStart;
}

-(void)setOnStart:(BOOL)start {
    onStart = start;
    [saveState setBool:onStart forKey:@"onStart"];
}

-(int)getTime {
    return timeElapsed;
}

-(void)setTime:(int)seconds {
    timeElapsed = seconds;
}

-(BOOL)getFinishedLevelPack:(int)level {
    return levelPacksFinished[level-1];
}

-(void)setFinishedLevelPack:(int)level {
    levelPacksFinished[level-1] = YES;
    [self saveLevelPacks];
}

-(BOOL)getFinishedLevel:(int)level {
    return levelsFinished[level-1];
}

-(void)setFinishedLevel:(int)level {
    levelsFinished[level-1] = YES;
    [self saveLevels];
}

-(int)getNumLevels {
    return numLevels;
}

-(int)getRated {
    rated = [saveState integerForKey:@"amIRated"];
    return rated;
}

-(void)setRated {
    rated = [saveState integerForKey:@"amIRated"];
    rated = 1;
    [saveState setInteger:1 forKey:@"amIRated"];
}


-(void)addNumVisits {
    numVisits = [saveState integerForKey:@"numberOfVisits"];
    if ((numVisits%5)==0) {
        numVisits = 0;
    }
    numVisits += 1;
    [saveState setInteger:numVisits forKey:@"numberOfVisits"];
    [saveState synchronize];
}

-(int)getNumVisits {
    numVisits = [saveState integerForKey:@"numberOfVisits"];
    return numVisits;
}


-(int)getNumStars:(int)forLevel {
    return practiceStars[forLevel-1];
}

-(void)setNumStars:(int)forLevel withStars:(int)stars {
    practiceStars[forLevel-1] = stars;
}

-(int)getCareerScore {
    return careerScore;
}
-(void)setCareerScore {
    int timeScore = careerStandardTime - totalTime;
    if (timeScore < 0) timeScore = 0;
    int deathScore = careerStandardDeaths - totalDeaths;
    if (deathScore < 0) deathScore = 0;
    careerScore = timeScore*101 + deathScore*1002 + 10452;
}
-(int)getCareerTime {
    return careerTime;
}
-(void)setCareerTime:(int)timeInSeconds {
    careerTime = timeInSeconds;
}
-(int)getCareerDeaths {
    return careerDeaths;
}
-(void)setCareerDeaths:(int)deaths {
    careerDeaths = deaths;
}
-(int)getTotalTime {
    return totalTime;
}
-(void)setTotalTime {
    totalTime += [self getCareerTime];
}
-(int)getTotalDeaths {
    return totalDeaths;
}
-(void)setTotalDeaths {
    totalDeaths += [self getCareerDeaths];
}
-(void)setCareerStandardTime:(int)timeInSeconds {
    careerStandardTime = timeInSeconds;
}
-(void)setCareerStandardDeaths:(int)deaths {
    careerStandardDeaths = deaths;
}
-(void)newLevelPack {
    careerScore = 0;
    careerTime = 0;
    careerDeaths = 0;
    careerStandardTime = 0;
    careerStandardDeaths = 0;
    totalTime = 0;
    totalDeaths = 0;
}

-(BOOL)getPractice {
    return inPracticeMode;
}

-(void)setPracticeMode:(BOOL)practice {
    inPracticeMode = practice;
}

-(BOOL)getNineLivesMode {
    return nineLivesMode;
}
-(void)setNineLivesMode:(BOOL)nineLives {
    nineLivesMode = nineLives;
}
-(int)getNineLivesLives {
    return nineLivesLives;
}
-(void)setNineLivesLives:(int)nineLives {
    nineLivesLives = nineLives;
}
-(BOOL)getNineLivesLevel:(int)level {
    return nineLivesArray[level-1];
}
-(void)setNineLivesLevel:(int)level isFinished:(BOOL)finished {
    nineLivesArray[level-1] = finished;
}
-(int)getRandomLevel {
    int value;
    nineLivesLevelsFinished++;
    if (nineLivesLevelsFinished == 41) {
        return 100;
    }
    for (;;) {
        value = arc4random() % 52;
        if (nineLivesArray[value] == NO) {
            if (value != 15 && value != 16 && value != 17 && value != 23 && value != 28 && value != 30 && value != 31 && value != 32 && value != 33 && value != 34 && value != 35 && value != 36) {
                return value;
            }
        }
    }
}

-(int)getNineLivesLevelsFinished {
    return nineLivesLevelsFinished;
}

-(int)getNineLivesScore {
    return nineLivesScore;
}
-(void)setNineLivesScore:(int)score {
    nineLivesScore = score;
}
-(void)resetNineLives {
    nineLivesLives = 9;
    nineLivesScore = 0;
    nineLivesLevelsFinished = 0;
    nineLivesTime = 0;
    for (int i = 0; i < sizeof(nineLivesArray); i++) {
        [self setNineLivesLevel:i+1 isFinished:NO];
    }
}
-(int)getNineLivesTime {
    return nineLivesTime;
}
-(void)setNineLivesTime:(int)time {
    nineLivesTime = time;
}

-(int)getLevelPackTopScoreForPack:(int)levelPack {
    return levelPackTopScores[levelPack-1];
}
-(void)setLevelPackTopScoreForPack:(int)levelPack withScore:(int)score {
    levelPackTopScores[levelPack-1] = score;
}
-(int)getNineLivesTopScore {
    return nineLivesTopScore;
}
-(void)setNineLivesTopScore:(int)score {
    nineLivesTopScore = score;
}
-(int)getLevelPackTopTimeForPack:(int)levelPack {
    return levelPackTopTimes[levelPack-1];
}
-(void)setLevelPackTopTimeForPack:(int)levelPack withTime:(int)time {
    levelPackTopTimes[levelPack-1] = time;
}
-(int)getLevelPackTopDeathsForPack:(int)levelPack {
    return levelPackTopDeaths[levelPack-1];
}
-(void)setLevelPackTopDeathsForPack:(int)levelPack withDeaths:(int)deaths {
    levelPackTopDeaths[levelPack-1] = deaths;
}
-(int)getNineLivesTopLevelsFinished {
    return nineLivesTopLevelsFinished;
}
-(void)setNineLivesTopLevelsFinished {
    nineLivesTopLevelsFinished = nineLivesLevelsFinished-1;
}
-(int)getNineLivesTopTime {
    return nineLivesTopTime;
}
-(void)setNineLivesTopTime {
    nineLivesTopTime = nineLivesTime;
}

-(void)saveLevels {
    for (int i = 0; i < sizeof(levelsFinished); i++) {
        [saveState setBool:levelsFinished[i] forKey:[NSString stringWithFormat:@"level%dFinished", i]];
    }
}

-(void)loadLevels {
    for (int i = 0; i < sizeof(levelsFinished); i++) {
        levelsFinished[i] = [saveState boolForKey:[NSString stringWithFormat:@"level%dFinished", i]];
    }
}

-(void)saveLevelPacks {
    for (int i = 0; i < sizeof(levelPacksFinished); i++) {
        [saveState setBool:levelPacksFinished[i] forKey:[NSString stringWithFormat:@"levelPack%dFinished", i]];
    }
}

-(void)loadLevelPacks {
    for (int i = 0; i < sizeof(levelPacksFinished); i++) {
        levelPacksFinished[i] = [saveState boolForKey:[NSString stringWithFormat:@"levelPack%dFinished", i]];
    }
}

-(void)saveStars {
    NSData *data = [NSData dataWithBytes:&practiceStars length:sizeof(practiceStars)];
    [saveState setObject:data forKey:@"levelStars"];
}

-(void)loadStars {
    NSData *data = [saveState objectForKey:@"levelStars"];
    memcpy(&practiceStars, data.bytes, data.length);
}

-(void)saveHighScores {
    NSData *data = [NSData dataWithBytes:&levelPackTopTimes length:sizeof(levelPackTopTimes)];
    [saveState setObject:data forKey:@"packHighTimes"];
    data = [NSData dataWithBytes:&levelPackTopDeaths length:sizeof(levelPackTopDeaths)];
    [saveState setObject:data forKey:@"packHighDeaths"];
    data = [NSData dataWithBytes:&levelPackTopScores length:sizeof(levelPackTopScores)];
    [saveState setObject:data forKey:@"packHighScores"];
    data = [NSData dataWithBytes:&nineLivesTopScore length:sizeof(nineLivesTopScore)];
    [saveState setObject:data forKey:@"nineLivesHighScore"];
    data = [NSData dataWithBytes:&nineLivesTopLevelsFinished length:sizeof(nineLivesTopLevelsFinished)];
    [saveState setObject:data forKey:@"nineLivesHighLevelsFinished"];
    data = [NSData dataWithBytes:&nineLivesTopTime length:sizeof(nineLivesTopTime)];
    [saveState setObject:data forKey:@"nineLivesHighTime"];
}

-(void)loadHighScores {
    NSData *data = [saveState objectForKey:@"packHighTimes"];
    memcpy(&levelPackTopTimes, data.bytes, data.length);
    data = [saveState objectForKey:@"packHighDeaths"];
    memcpy(&levelPackTopDeaths, data.bytes, data.length);
    data = [saveState objectForKey:@"packHighScores"];
    memcpy(&levelPackTopScores, data.bytes, data.length);
    data = [saveState objectForKey:@"nineLivesHighScore"];
    memcpy(&nineLivesTopScore, data.bytes, data.length);
    data = [saveState objectForKey:@"nineLivesHighLevelsFinished"];
    memcpy(&nineLivesTopLevelsFinished, data.bytes, data.length);
    data = [saveState objectForKey:@"nineLivesHighTime"];
    memcpy(&nineLivesTopTime, data.bytes, data.length);
}

-(BOOL)getPauseMusic {
    return pauseMusic;
}

-(void)setPauseMusic:(BOOL)pause {
    pauseMusic = pause;
}

-(BOOL)getPauseSound {
    return pauseSounds;
}

-(void)setPauseSound:(BOOL)pause {
    pauseSounds = pause;
}

@end
