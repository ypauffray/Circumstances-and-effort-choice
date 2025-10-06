import time
import json

from otree import settings
from otree.api import *

from .image_utils import encode_image
from . import task_sliders

doc = """
"""

class C(BaseConstants):
    NAME_IN_URL = "sliders"
    PLAYERS_PER_GROUP = None #one third party and two players from effort phase
    TASK_DURATION = 2700 #45 minutes
    ONE_TASK_DURATION = 600 #10 minutes for the individual slider task in stage 3
    TIMER_TEXT = "Time to complete the stage:"
    TARGET = 2500
    NUM_SLIDERS = 300
    SKILL_LB = 0
    SKILL_UB_HIGH = 20
    SKILL_UB_LOW = 10
    CAPITAL_MEAN = 1250
    DELTA_HIGH = 1250
    DELTA_LOW = 0
    CAPITAL_LB_HIGH = CAPITAL_MEAN - DELTA_HIGH #FOR SLIDER LIMITS WHEN ELICITING BELIEFS
    CAPITAL_UB_HIGH = CAPITAL_MEAN + DELTA_HIGH #FOR SLIDER LIMITS WHEN ELICITING BELIEFS
    REWARD = 100
    BONUS = 100
    TREATMENT = ['High-Low', 'Low-Low', 'High-Low', 'Low-High', 'High-Low']
    TREATMENT_STG2 = ['High-Low', 'Low-Low', 'Low-High']
    NUM_ROUNDS_STG1 = len(TREATMENT)
    NUM_ROUNDS_STG2 = len(TREATMENT_STG2)
    NUM_ROUNDS = len(TREATMENT) + len(TREATMENT_STG2) + 2
    SHARE_BOTH_LIB = 50
    SHARE_REACH_LIB = 100
    SHARE_MISS_LIB = 0

class Subsession(BaseSubsession):
    pass

class Group(BaseGroup):
    pass

class Player(BasePlayer):
    # only suported 1 iteration for now
    iteration = models.IntegerField(initial=0)
    num_correct = models.IntegerField(initial=0)
    elapsed_time = models.FloatField(initial=0)
    num_participants = models.IntegerField(initial=0)
    treatment1 = models.StringField()
    treatment2 = models.StringField()
    treatment3 = models.StringField()
    treatment4 = models.StringField()
    treatment5 = models.StringField()
    treatment6 = models.StringField()
    treatment7 = models.StringField()
    treatment8 = models.StringField()
    info = models.IntegerField(initial=0)
    round_firstHL = models.IntegerField(initial=0)
    round_firstLL = models.IntegerField(initial=0)
    round_firstLH = models.IntegerField(initial=0)
    current_treatment = models.StringField()
    current_task = models.StringField()
    first_name = models.StringField(label="First name", )
    last_name = models.StringField(label="Last name", )
    email = models.StringField(label="Email", )
    address = models.StringField(label="Address", )
    city = models.StringField(label="City", )
    student_id = models.IntegerField(label="Student ID", min=100000, max=999999, )
    SSN = models.StringField(label="Social Security Number (SSN). You can refuse to provide a SSN, if so please enter REFUSE. If you are a foreign national and do not have a SSN, please enter FOREIGN.",)
    gender = models.IntegerField(
        label="Gender",
        choices=[[1, "Male"], [2, "Female"], [3, "Other or prefer not to say"]]
    )
    politics_GSS = models.IntegerField(
        label="Generally speaking, do you usually think of yourself as a Republican, Democrat, Independent,"
              " or other?",
        choices=[
            [1, "Strong Democrat"], [2, "Not very strong Democrat"], [3, "Independent, close to Democrat"],
            [4, "Independent"], [5, "Independent, close to Republican"], [6, "Not very strong Republican"],
            [7, "Strong Republican"], [8, "Don't know or refuse to say"],
        ]
    )
    escape_poverty_WVS = models.IntegerField(
        label="Most poor people in the United States have a chance of escaping from poverty",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    )
    inequality_Stan = models.IntegerField(
        label="Indicate to what extent you think that it is fair or unfair that there are differences"
               " in income in our society",
        choices=[[1, "Completely fair"], [2, "Somewhat fair"], [3, "Neither fair nor unfair"],
                 [4, "Somewhat unfair"], [5, "Completely unfair"],
                 ]
    ) #Stantcheva
    luck_vs_effort = models.IntegerField(
        label="Indicate to what extent you think that differences in income are caused by differences in people's efforts" 
            " over their lifetime or rather by luck? By luck, we mean conditions, which you" 
            " have no control over.",
        choices=[
            [1, "Only luck"], [2, "Mostly luck"], [3, "Equally important"],
            [4, "Mostly effort"], [5, "Only effort"],
        ]
    )#Stantcheva
    inequality_perception = models.IntegerField(
        label="Income inequality is a problem in the United States",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    )#Stantcheva Social Position and Fairness Views
    gov_redistribution = models.IntegerField(
        label="The government should increase redistribution of income by increasing taxes and transfers to reduce inequality",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    )#Stantcheva Social Position and Fairness Views
    rich_merit = models.IntegerField(
        label="People with high incomes have worked hard for their income and deserve it",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    )#Stantcheva Social Position and Fairness Views
    poor_lazy = models.IntegerField(
        label="If a person is poor this is mainly due to lack of effort from their side",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    )#Stantcheva Social Position and Fairness Views
    inequality_useful = models.IntegerField(
        label="Only if differences in income and social standing are large enough is there an incentive for individual effort",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    ) #GSS USCLASS6
    social_mobility2 = models.IntegerField(
        label="In the United States there are still great differences between social levels, "
              " and what one can achieve in life depends mainly upon one's family background",
        choices=[
            [1, "Completely agree"], [2, "Somewhat agree"], [3, "Neither agree nor disagree"],
            [4, "Somewhat disagree"], [5, "Completely disagree"],
        ]
    ) #GSS USCLASS2
    social_class = models.IntegerField(
        label="If you were asked to use one of five names for your socio-economic class, which would you say you belong in:",
        choices=[
            [1, "Lower class"], [2, "Lower-middle class"], [3, "Middle class"],
            [4, "Upper-middle class"], [5, "Upper class"], [6, "Don't know or refuse to say"]
        ]
    )#GSS CLASSY question but answers adapted
    skill_draw = models.FloatField(initial=0)
    capital_draw = models.FloatField(initial=0)
    output = models.FloatField(initial=0)
    distance_to_target = models.FloatField(initial=0)
    target_is_reached = models.IntegerField(initial=0)
    target_reached_HL = models.IntegerField(initial=0)
    target_reached_LL = models.IntegerField(initial=0)
    target_reached_LH = models.IntegerField(initial=0)
    target_missed_HL = models.IntegerField(initial=0)
    target_missed_LL = models.IntegerField(initial=0)
    target_missed_LH = models.IntegerField(initial=0)
    give_lucky = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    send_unlucky = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    check_send_unlucky = models.IntegerField(blank=True)
    give_merit = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    send_lazy = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    check_send_lazy = models.IntegerField(blank=True)
    give_winner = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    send_loser = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    check_send_loser = models.IntegerField(blank=True)
    give_winner_pair1 = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    send_loser_pair1 = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    check_send_loser_pair1 = models.IntegerField(blank=True)
    give_winner_pair2 = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    send_loser_pair2 = models.IntegerField(min=0, max=C.BONUS, initial=0, blank=True)
    check_send_loser_pair2 = models.IntegerField(blank=True)
    points_from_redistribution = models.IntegerField(min=0, max=C.BONUS, initial=1, blank=True)#inital=1 because can't check if field empty
    belief_avg_capital_reach = models.IntegerField(min=0, max=C.CAPITAL_UB_HIGH, initial=0, blank=True) #belief
    belief_avg_capital_miss = models.IntegerField(min=0, max=C.CAPITAL_UB_HIGH, initial=0, blank=True) #belief
    belief_avg_effort_reach = models.IntegerField(min=0, max=C.NUM_SLIDERS, initial=0, blank=True) #belief
    belief_avg_effort_miss = models.IntegerField(min=0, max=C.NUM_SLIDERS, initial=0, blank=True) #belief
    belief_avg_skill_miss = models.FloatField(min=0, max=C.SKILL_UB_HIGH, initial=0, blank=True) #belief
    belief_avg_skill_reach = models.FloatField(min=0, max=C.SKILL_UB_HIGH, initial=0, blank=True) #belief
    belief_effort_reach_pair1 = models.IntegerField(min=0, max=C.NUM_SLIDERS, initial=0, blank=True) #belief
    belief_effort_miss_pair1 = models.IntegerField(min=0, max=C.NUM_SLIDERS, initial=0, blank=True)  # belief
    belief_skill_miss_pair1 = models.FloatField(min=0, max=C.SKILL_UB_HIGH, initial=0, blank=True) #belief
    belief_skill_reach_pair1 = models.FloatField(min=0, max=C.SKILL_UB_HIGH, initial=0, blank=True) #belief
    belief_effort_reach_pair2 = models.IntegerField(min=0, max=C.NUM_SLIDERS, initial=0, blank=True)  # belief
    belief_effort_miss_pair2 = models.IntegerField(min=0, max=C.NUM_SLIDERS, initial=0, blank=True)  # belief
    belief_skill_miss_pair2 = models.FloatField(min=0, max=C.SKILL_UB_HIGH, initial=0, blank=True)  # belief
    belief_skill_reach_pair2 = models.FloatField(min=0, max=C.SKILL_UB_HIGH, initial=0, blank=True)  # belief
    check_belief_effort_reach_pair1 = models.IntegerField(blank=True)  # belief
    check_belief_effort_miss_pair1 = models.IntegerField(blank=True)  # belief
    check_belief_skill_miss_pair1 = models.FloatField(blank=True)  # belief
    check_belief_skill_reach_pair1 = models.FloatField(blank=True)  # belief
    check_belief_effort_reach_pair2 = models.IntegerField(blank=True)  # belief
    check_belief_effort_miss_pair2 = models.IntegerField(blank=True)  # belief
    check_belief_skill_miss_pair2 = models.FloatField(blank=True)  # belief
    check_belief_skill_reach_pair2 = models.FloatField(blank=True)  # belief

    check_belief_avg_capital_reach = models.IntegerField(blank=True)
    check_belief_avg_skill_reach = models.IntegerField(blank=True)
    check_belief_avg_effort_reach = models.IntegerField(blank=True)
    check_belief_avg_capital_miss = models.IntegerField(blank=True)
    check_belief_avg_skill_miss = models.IntegerField(blank=True)
    check_belief_avg_effort_miss = models.IntegerField(blank=True)
    amount_from_redistribution = models.IntegerField(initial=0)
    earnings = models.IntegerField(initial=0)
    slider_earnings = models.IntegerField(initial=0)
    total_effort_allrounds = models.IntegerField(initial=0)
    effort_reach_HL = models.IntegerField(initial=0)
    effort_miss_HL = models.IntegerField(initial=0)
    skill_reach_HL = models.FloatField(initial=0)
    skill_miss_HL = models.FloatField(initial=0)
    capital_reach_HL = models.FloatField(initial=0)
    capital_miss_HL = models.FloatField(initial=0)
    effort_reach_LL = models.IntegerField(initial=0)
    effort_miss_LL = models.IntegerField(initial=0)
    skill_reach_LL = models.FloatField(initial=0)
    skill_miss_LL = models.FloatField(initial=0)
    capital_reach_LL = models.FloatField(initial=0)
    capital_miss_LL = models.FloatField(initial=0)
    effort_reach_LH = models.IntegerField(initial=0)
    effort_miss_LH = models.IntegerField(initial=0)
    skill_reach_LH = models.FloatField(initial=0)
    skill_miss_LH = models.FloatField(initial=0)
    capital_reach_LH = models.FloatField(initial=0)
    capital_miss_LH = models.FloatField(initial=0)
    avg_effort_reach_LH_allplayers = models.FloatField(initial=0)
    avg_effort_miss_LH_allplayers = models.FloatField(initial=0)
    avg_effort_reach_HL_allplayers = models.FloatField(initial=0)
    avg_effort_miss_HL_allplayers = models.FloatField(initial=0)
    avg_effort_reach_LL_allplayers = models.FloatField(initial=0)
    avg_effort_miss_LL_allplayers = models.FloatField(initial=0)
    avg_skill_reach_LH_allplayers = models.FloatField(initial=0)
    avg_skill_miss_LH_allplayers = models.FloatField(initial=0)
    avg_skill_reach_HL_allplayers = models.FloatField(initial=0)
    avg_skill_miss_HL_allplayers = models.FloatField(initial=0)
    avg_skill_reach_LL_allplayers = models.FloatField(initial=0)
    avg_skill_miss_LL_allplayers = models.FloatField(initial=0)
    avg_capital_reach_LH_allplayers = models.FloatField(initial=0)
    avg_capital_miss_LH_allplayers = models.FloatField(initial=0)
    avg_capital_reach_HL_allplayers = models.FloatField(initial=0)
    avg_capital_miss_HL_allplayers = models.FloatField(initial=0)
    avg_capital_reach_LL_allplayers = models.FloatField(initial=0)
    avg_capital_miss_LL_allplayers = models.FloatField(initial=0)
    num_reach_LL_allrounds = models.IntegerField(initial=0)
    num_miss_LL_allrounds = models.IntegerField(initial=0)
    num_reach_LH_allrounds = models.IntegerField(initial=0)
    num_miss_LH_allrounds = models.IntegerField(initial=0)
    num_reach_HL_allrounds = models.IntegerField(initial=0)
    num_miss_HL_allrounds = models.IntegerField(initial=0)
    total_capital_miss_HL_allrounds = models.FloatField(initial=0)
    total_capital_miss_LL_allrounds = models.FloatField(initial=0)
    total_capital_miss_LH_allrounds = models.FloatField(initial=0)
    total_skill_miss_HL_allrounds = models.FloatField(initial=0)
    total_skill_miss_LL_allrounds = models.FloatField(initial=0)
    total_skill_miss_LH_allrounds = models.FloatField(initial=0)
    total_effort_miss_HL_allrounds = models.IntegerField(initial=0)
    total_effort_miss_LL_allrounds = models.IntegerField(initial=0)
    total_effort_miss_LH_allrounds = models.IntegerField(initial=0)
    total_capital_reach_HL_allrounds = models.FloatField(initial=0)
    total_capital_reach_LL_allrounds = models.FloatField(initial=0)
    total_capital_reach_LH_allrounds = models.FloatField(initial=0)
    total_skill_reach_HL_allrounds = models.FloatField(initial=0)
    total_skill_reach_LL_allrounds = models.FloatField(initial=0)
    total_skill_reach_LH_allrounds = models.FloatField(initial=0)
    total_effort_reach_HL_allrounds = models.IntegerField(initial=0)
    total_effort_reach_LL_allrounds = models.IntegerField(initial=0)
    total_effort_reach_LH_allrounds = models.IntegerField(initial=0)
    num_reach_LL_allplayers = models.IntegerField(initial=0)
    num_miss_LL_allplayers = models.IntegerField(initial=0)
    num_reach_HL_allplayers = models.IntegerField(initial=0)
    num_miss_HL_allplayers = models.IntegerField(initial=0)
    num_reach_LH_allplayers = models.IntegerField(initial=0)
    num_miss_LH_allplayers = models.IntegerField(initial=0)
    num_reach_stage3 = models.IntegerField(initial=0) #to know if I can display pairs or not
    num_miss_stage3 = models.IntegerField(initial=0)  # to know if I can display pairs or not
    earnings_capital_reach_HL = models.FloatField(initial=0)  #pay for beliefs
    earnings_capital_miss_HL = models.FloatField(initial=0) #pay for beliefs
    earnings_skill_reach_HL = models.FloatField(initial=0) #pay for beliefs
    earnings_skill_miss_HL = models.FloatField(initial=0)   #pay for beliefs
    earnings_effort_reach_HL = models.FloatField(initial=0) #pay for beliefs
    earnings_effort_miss_HL = models.FloatField(initial=0)  # pay for beliefs
    earnings_skill_reach_LL = models.FloatField(initial=0) #pay for beliefs
    earnings_skill_miss_LL = models.FloatField(initial=0)   #pay for beliefs
    earnings_effort_reach_LL = models.FloatField(initial=0) #pay for beliefs
    earnings_effort_miss_LL = models.FloatField(initial=0)  # pay for beliefs
    earnings_skill_reach_LH = models.FloatField(initial=0) #pay for beliefs
    earnings_skill_miss_LH = models.FloatField(initial=0)   #pay for beliefs
    earnings_effort_reach_LH = models.FloatField(initial=0) #pay for beliefs
    earnings_effort_miss_LH = models.FloatField(initial=0)  # pay for beliefs
    belief_earnings = models.FloatField(initial=0)
    total_payoff = models.FloatField(initial=0)
    capital_reach_pair1 = models.FloatField(initial=0)
    capital_reach_pair2 = models.FloatField(initial=0)
    capital_miss_pair1 = models.FloatField(initial=0)
    capital_miss_pair2 = models.FloatField(initial=0)
    effort_reach_pair1 = models.FloatField(initial=0)
    effort_reach_pair2 = models.FloatField(initial=0)
    effort_miss_pair1 = models.FloatField(initial=0)
    effort_miss_pair2 = models.FloatField(initial=0)
    skill_reach_pair1 = models.FloatField(initial=0)
    skill_reach_pair2 = models.FloatField(initial=0)
    skill_miss_pair1 = models.FloatField(initial=0)
    skill_miss_pair2 = models.FloatField(initial=0)
    q1 = models.BooleanField(
        label='''Which of the following statement is true:''',
        choices=[
            [False, "You are expected to correctly position all 300 sliders in each task."],
            [True, "How many sliders you decide to correctly position is up to you. You don't have to correctly position all the sliders in each task."],
        ]
    )
    q2 = models.BooleanField(
        label='''Suppose that your randomly selected starting line is 1000 and your randomly selected multiplier value is 3.
         If you correctly position 150 sliders (i.e. your slider score is 150), what will be your production value? ''',
        choices=[
            [False, "150+(3*1000)=3150"], [True, "1000+(3*150)=1450"]
        ]
    )
    q3 = models.BooleanField(
        label='''
        Which of the following statement is true:''',
        choices=[
            [True, "The possible ranges for your starting line and multiplier may change depending on the round."],
            [False, "The possible ranges for your starting line and multiplier are the same in every round."],
        ]
    )
    q4 = models.BooleanField(
        label='''If your production exceeds the target, which of the following is true:
        ''',
        choices=[
            [False, "The greater your production, the more points you will earn."],
            [True, "It does not matter by how much your production exceeds the target. As soon as you reach the target, "
                   "you will receive 100 points."],
        ]
    )
    q5 = models.BooleanField(
        label='''The closer your guess is to the truth, the more points you will receive.
        ''',
        choices=[
            [True, "True"],
            [False, "False"],
        ]
    )
    time_spent = models.FloatField(initial=0) #time spent on providing beliefs which is added to the timer
    time_spent_feedback = models.FloatField(initial=0)  # time spent on feedback page which is added to the timer
    time_spent_rule = models.FloatField(initial=0)  # time added to the timer
    time_spent_reveal = models.FloatField(initial=0)  # time added to the timer

def get_timeout_seconds1(player: Player):
    participant = player.participant
    import time
    if player.round_number == C.NUM_ROUNDS - 1: # timer for the single slider task at stage 3
        return C.ONE_TASK_DURATION
    else:
        return participant.expiry - time.time() + player.in_round(1).time_spent + player.in_round(2).time_spent + \
               player.in_round(3).time_spent + player.in_round(4).time_spent + player.in_round(1).time_spent_feedback + \
               player.in_round(2).time_spent_feedback + player.in_round(3).time_spent_feedback + player.in_round(4).time_spent_feedback + \
               player.in_round(2).time_spent_rule + player.in_round(3).time_spent_rule + player.in_round(4).time_spent_rule +\
               player.in_round(5).time_spent_rule + player.in_round(2).time_spent_reveal + player.in_round(3).time_spent_reveal + player.in_round(4).time_spent_reveal + player.in_round(5).time_spent_reveal

def is_displayed1(player: Player):
    """only returns True if there is time left."""
    return get_timeout_seconds1(player) > 0

def creating_session(subsession: Subsession):
    session = subsession.session
    import random
    defaults = dict(
        trial_delay=1.0,
        retry_delay=0.1,
        num_sliders=C.NUM_SLIDERS,
        num_columns=3,
        attempts_per_slider=10
    )
    session.params = {}
    for param in defaults:
        session.params[param] = session.config.get(param, defaults[param])

    if subsession.round_number == 1:
        for player in subsession.get_players():
            treatments = ['High-Low', 'High-Low', 'High-Low', 'Low-Low', 'Low-High']
            treatments2 = ['High-Low', 'Low-Low', 'Low-High']
            random.shuffle(treatments)
            random.shuffle(treatments2)
            player.treatment1 = treatments[0]
            player.treatment2 = treatments[1]
            player.treatment3 = treatments[2]
            player.treatment4 = treatments[3]
            player.treatment5 = treatments[4]
            player.treatment6 = treatments2[0]
            player.treatment7 = treatments2[1]
            player.treatment8 = treatments2[2]
            if player.treatment1 == 'High-Low':
                player.round_firstHL = 1
            if player.treatment1 != 'High-Low' and player.treatment2 == 'High-Low':
                player.round_firstHL = 2
            if player.treatment1 != 'High-Low' and player.treatment2 != 'High-Low' and player.treatment3 == 'High-Low':
                player.round_firstHL = 3

            if player.treatment1 == 'Low-Low':
                player.round_firstLL = 1
            if player.treatment2 == 'Low-Low':
                player.round_firstLL = 2
            if player.treatment3 == 'Low-Low':
                player.round_firstLL = 3
            if player.treatment4 == 'Low-Low':
                player.round_firstLL = 4
            if player.treatment5 == 'Low-Low':
                player.round_firstLL = 5

            if player.treatment1 == 'Low-High':
                player.round_firstLH = 1
            if player.treatment2 == 'Low-High':
                player.round_firstLH = 2
            if player.treatment3 == 'Low-High':
                player.round_firstLH = 3
            if player.treatment4 == 'Low-High':
                player.round_firstLH = 4
            if player.treatment5 == 'Low-High':
                player.round_firstLH = 5

    for player in subsession.get_players():
        player.num_participants = session.num_participants
        player.treatment1 = player.in_round(1).treatment1
        player.treatment2 = player.in_round(1).treatment2
        player.treatment3 = player.in_round(1).treatment3
        player.treatment4 = player.in_round(1).treatment4
        player.treatment5 = player.in_round(1).treatment5
        player.treatment6 = player.in_round(1).treatment6
        player.treatment7 = player.in_round(1).treatment7
        player.treatment8 = player.in_round(1).treatment8
        player.round_firstHL = player.in_round(1).round_firstHL
        player.round_firstLL = player.in_round(1).round_firstLL
        player.round_firstLH = player.in_round(1).round_firstLH

        if subsession.round_number == 1:
            player.current_treatment = player.treatment1
        if subsession.round_number == 2:
            player.current_treatment = player.treatment2
        if subsession.round_number == 3:
            player.current_treatment = player.treatment3
        if subsession.round_number == 4:
            player.current_treatment = player.treatment4
        if subsession.round_number == 5:
            player.current_treatment = player.treatment5
        if subsession.round_number == 6:
            player.current_treatment = player.treatment6
        if subsession.round_number == 7:
            player.current_treatment = player.treatment7
        if subsession.round_number == 8:
            player.current_treatment = player.treatment8
        if subsession.round_number > 8:
            player.current_treatment = 'High-Low'
            player.info = 1

        if subsession.round_number <= len(C.TREATMENT) or subsession.round_number == C.NUM_ROUNDS - 1:
            player.current_task = 'Effort'
        else:
            player.current_task = 'Redistribute'

        if player.current_treatment == 'High-Low':
            player.capital_draw = round(random.uniform(C.CAPITAL_MEAN-C.DELTA_HIGH, C.CAPITAL_MEAN+C.DELTA_HIGH), 0)
            player.skill_draw = round(random.uniform(C.SKILL_LB, C.SKILL_UB_LOW), 0)
        else:
            if player.current_treatment == 'Low-Low':
                player.capital_draw = round(random.uniform(C.CAPITAL_MEAN - C.DELTA_LOW, C.CAPITAL_MEAN + C.DELTA_LOW), 0)
                player.skill_draw = round(random.uniform(C.SKILL_LB, C.SKILL_UB_LOW), 0)
            else:
                player.capital_draw = round(random.uniform(C.CAPITAL_MEAN - C.DELTA_LOW, C.CAPITAL_MEAN + C.DELTA_LOW), 0)
                player.skill_draw = round(random.uniform(C.SKILL_LB, C.SKILL_UB_HIGH), 0)

# puzzle-specific stuff

class Puzzle(ExtraModel):
    """A model to keep record of sliders setup"""

    player = models.Link(Player)
    iteration = models.IntegerField()
    timestamp = models.FloatField()

    num_sliders = models.IntegerField()
    layout = models.LongStringField()

    response_timestamp = models.FloatField()
    num_correct = models.IntegerField(initial=0)
    is_solved = models.BooleanField(initial=False)


class Slider(ExtraModel):
    """A model to keep record of each slider"""

    puzzle = models.Link(Puzzle)
    idx = models.IntegerField()
    target = models.IntegerField()
    value = models.IntegerField()
    is_correct = models.BooleanField(initial=False)
    attempts = models.IntegerField(initial=0)


def generate_puzzle(player: Player) -> Puzzle:
    """Create new puzzle for a player"""
    params = player.session.params
    num = params['num_sliders']
    layout = task_sliders.generate_layout(params)
    puzzle = Puzzle.create(
        player=player, iteration=player.iteration, timestamp=time.time(),
        num_sliders=num,
        layout=json.dumps(layout)
    )
    for i in range(num):
        target, initial = task_sliders.generate_slider()
        Slider.create(
            puzzle=puzzle,
            idx=i,
            target=target,
            value=initial
        )
    return puzzle


def get_current_puzzle(player):
    puzzles = Puzzle.filter(player=player, iteration=player.iteration)
    if puzzles:
        [puzzle] = puzzles
        return puzzle


def get_slider(puzzle, idx):
    sliders = Slider.filter(puzzle=puzzle, idx=idx)
    if sliders:
        [puzzle] = sliders
        return puzzle


def encode_puzzle(puzzle: Puzzle):
    """Create data describing puzzle to send to client"""
    layout = json.loads(puzzle.layout)
    sliders = Slider.filter(puzzle=puzzle)
    # generate image for the puzzle
    image = task_sliders.render_image(layout, targets=[s.target for s in sliders])
    return dict(
        image=encode_image(image),
        size=layout['size'],
        grid=layout['grid'],
        sliders={s.idx: {'value': s.value, 'is_correct': s.is_correct} for s in sliders}
    )


def get_progress(player: Player):
    """Return current player progress"""
    return dict(
        iteration=player.iteration,
        solved=player.num_correct
    )


def handle_response(puzzle, slider, value):
    slider.value = task_sliders.snap_value(value, slider.target)
    slider.is_correct = slider.value == slider.target
    puzzle.num_correct = len(Slider.filter(puzzle=puzzle, is_correct=True))
    puzzle.is_solved = puzzle.num_correct == puzzle.num_sliders


def play_game(player: Player, message: dict):
    """Main game workflow
    Implemented as reactive scheme: receive message from browser, react, respond.

    Generic game workflow, from server point of view:
    - receive: {'type': 'load'} -- empty message means page loaded
    - check if it's game start or page refresh midgame
    - respond: {'type': 'status', 'progress': ...}
    - respond: {'type': 'status', 'progress': ..., 'puzzle': data}
      in case of midgame page reload

    - receive: {'type': 'new'} -- request for a new puzzle
    - generate new sliders
    - respond: {'type': 'puzzle', 'puzzle': data}

    - receive: {'type': 'value', 'slider': ..., 'value': ...} -- submitted value of a slider
      - slider: the index of the slider
      - value: the value of slider in pixels
    - check if the answer is correct
    - respond: {'type': 'feedback', 'slider': ..., 'value': ..., 'is_correct': ..., 'is_completed': ...}
      - slider: the index of slider submitted
      - value: the value aligned to slider steps
      - is_correct: if submitted value is correct
      - is_completed: if all sliders are correct
    """
    session = player.session
    my_id = player.id_in_group
    params = session.params

    now = time.time()
    # the current puzzle or none
    puzzle = get_current_puzzle(player)

    message_type = message['type']

    if message_type == "load":
        p = get_progress(player)
        if puzzle:
            return {my_id: dict(type='status', progress=p, puzzle=encode_puzzle(puzzle))}
        else:
            return {my_id: dict(type='status', progress=p)}

    if message_type == "new":
        if puzzle is not None:
            raise RuntimeError("trying to create 2nd puzzle")

        player.iteration += 1
        z = generate_puzzle(player)
        p = get_progress(player)

        return {my_id: dict(type='puzzle', puzzle=encode_puzzle(z), progress=p, solved=player.num_correct)}

    if message_type == "value":
        if puzzle is None:
            raise RuntimeError("missing puzzle")
        if puzzle.response_timestamp and now < puzzle.response_timestamp + params["retry_delay"]:
            raise RuntimeError("retrying too fast")

        slider = get_slider(puzzle, int(message["slider"]))

        if slider is None:
            raise RuntimeError("missing slider")
        if slider.attempts >= params['attempts_per_slider']:
            raise RuntimeError("too many slider motions")

        value = int(message["value"])
        handle_response(puzzle, slider, value)
        puzzle.response_timestamp = now
        slider.attempts += 1
        player.num_correct = puzzle.num_correct

        p = get_progress(player)
        return {
            my_id: dict(
                type='feedback', slider=slider.idx, value=slider.value,
                is_correct=slider.is_correct, is_completed=puzzle.is_solved,
                progress=p, solved=player.num_correct
            )
        }

    if message_type == "cheat" and settings.DEBUG:
        return {my_id: dict(type='solution', solution={s.idx: s.target for s in Slider.filter(puzzle=puzzle)})}

    raise RuntimeError("unrecognized message from client")

class Game(Page):
    is_displayed = is_displayed1
    get_timeout_seconds = get_timeout_seconds1
    timer_text = C.TIMER_TEXT
    live_method = play_game

    @staticmethod
    def is_displayed(player: Player):
        return player.current_task == 'Effort'

    @staticmethod
    def js_vars(player: Player):
        return dict(
            params=player.session.params, slider_size=task_sliders.SLIDER_BBOX,
            solved=player.num_correct, progress=get_progress(player),
            progress_solved=get_progress(player)['solved']
        )

    @staticmethod
    def vars_for_template(player: Player):
        return dict(
            params=player.session.params, DEBUG=settings.DEBUG,
            solved=player.num_correct, progress=get_progress(player),
            progress_solved=get_progress(player)['solved']
        )

    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        puzzle = get_current_puzzle(player)

        if puzzle and puzzle.response_timestamp:
            player.elapsed_time = puzzle.response_timestamp - puzzle.timestamp
            player.num_correct = puzzle.num_correct

        player.output = round((player.skill_draw * player.num_correct + player.capital_draw), 2)
        player.distance_to_target = round((C.TARGET - player.capital_draw - player.skill_draw * player.num_correct), 2)
        if player.distance_to_target <= 0:
            player.target_is_reached = 1
            player.earnings = C.REWARD
        if player.target_is_reached == 0:
            player.earnings = 0

        if player.current_treatment == 'High-Low':
            if player.target_is_reached == 1:
                player.effort_reach_HL = player.num_correct
                player.skill_reach_HL = player.skill_draw
                player.capital_reach_HL = player.capital_draw
                player.target_reached_HL = 1
            else:
                player.effort_miss_HL = player.num_correct
                player.skill_miss_HL = player.skill_draw
                player.capital_miss_HL = player.capital_draw
                player.target_missed_HL = 1

        if player.current_treatment == 'Low-Low':
            if player.target_is_reached == 1:
                player.effort_reach_LL = player.num_correct
                player.skill_reach_LL = player.skill_draw
                player.capital_reach_LL = player.capital_draw
                player.target_reached_LL = 1
            else:
                player.effort_miss_LL = player.num_correct
                player.skill_miss_LL = player.skill_draw
                player.capital_miss_LL = player.capital_draw
                player.target_missed_LL = 1

        if player.current_treatment == 'Low-High':
            if player.target_is_reached == 1:
                player.effort_reach_LH = player.num_correct
                player.skill_reach_LH = player.skill_draw
                player.capital_reach_LH = player.capital_draw
                player.target_reached_LH = 1
            else:
                player.effort_miss_LH = player.num_correct
                player.skill_miss_LH = player.skill_draw
                player.capital_miss_LH = player.capital_draw
                player.target_missed_LH = 1

        if player.round_number == len(C.TREATMENT):
            player.total_effort_allrounds = sum([p.num_correct for p in player.in_all_rounds()])
            player.num_reach_LL_allrounds = sum([p.target_reached_LL for p in player.in_all_rounds()])
            player.num_miss_LL_allrounds = sum([p.target_missed_LL for p in player.in_all_rounds()])
            player.num_reach_LH_allrounds = sum([p.target_reached_LH for p in player.in_all_rounds()])
            player.num_miss_LH_allrounds = sum([p.target_missed_LH for p in player.in_all_rounds()])
            player.num_reach_HL_allrounds = sum([p.target_reached_HL for p in player.in_all_rounds()])
            player.num_miss_HL_allrounds = sum([p.target_missed_HL for p in player.in_all_rounds()])
            player.total_capital_miss_HL_allrounds = sum([p.capital_miss_HL for p in player.in_all_rounds()])
            player.total_capital_miss_LL_allrounds = sum([p.capital_miss_LL for p in player.in_all_rounds()])
            player.total_capital_miss_LH_allrounds = sum([p.capital_miss_LH for p in player.in_all_rounds()])
            player.total_skill_miss_HL_allrounds = sum([p.skill_miss_HL for p in player.in_all_rounds()])
            player.total_skill_miss_LL_allrounds = sum([p.skill_miss_LL for p in player.in_all_rounds()])
            player.total_skill_miss_LH_allrounds = sum([p.skill_miss_LH for p in player.in_all_rounds()])
            player.total_effort_miss_HL_allrounds = sum([p.effort_miss_HL for p in player.in_all_rounds()])
            player.total_effort_miss_LL_allrounds = sum([p.effort_miss_LL for p in player.in_all_rounds()])
            player.total_effort_miss_LH_allrounds = sum([p.effort_miss_LH for p in player.in_all_rounds()])
            player.total_capital_reach_HL_allrounds = sum([p.capital_reach_HL for p in player.in_all_rounds()])
            player.total_capital_reach_LL_allrounds = sum([p.capital_reach_LL for p in player.in_all_rounds()])
            player.total_capital_reach_LH_allrounds = sum([p.capital_reach_LH for p in player.in_all_rounds()])
            player.total_skill_reach_HL_allrounds = sum([p.skill_reach_HL for p in player.in_all_rounds()])
            player.total_skill_reach_LL_allrounds = sum([p.skill_reach_LL for p in player.in_all_rounds()])
            player.total_skill_reach_LH_allrounds = sum([p.skill_reach_LH for p in player.in_all_rounds()])
            player.total_effort_reach_HL_allrounds = sum([p.effort_reach_HL for p in player.in_all_rounds()])
            player.total_effort_reach_LL_allrounds = sum([p.effort_reach_LL for p in player.in_all_rounds()])
            player.total_effort_reach_LH_allrounds = sum([p.effort_reach_LH for p in player.in_all_rounds()])

        if player.round_number == C.NUM_ROUNDS - 1:#last effort
            player.slider_earnings = sum([p.earnings for p in player.in_all_rounds()])

class Welcome(Page):
    form_model = 'player'
    form_fields = ['first_name', 'last_name', 'gender', 'student_id', 'address', 'city', 'SSN', 'email']

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1

class Rule(Page):
    form_model = 'player'
    form_fields = ['time_spent_rule']

    @staticmethod
    def is_displayed(player: Player):
        return player.current_task == 'Effort'

class Reveal_draws(Page):

    form_model = 'player'
    form_fields = ['time_spent_reveal']

    @staticmethod
    def is_displayed(player: Player):
        return player.current_task == 'Effort'

    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        if player.round_number == 1:
            participant = player.participant
            import time
            participant.expiry = time.time() + C.TASK_DURATION

class Belief_reach(Page):

    form_model = 'player'
    form_fields = ['belief_avg_capital_reach', 'belief_avg_effort_reach', 'belief_avg_skill_reach',
                   'belief_avg_capital_miss', 'belief_avg_effort_miss', 'belief_avg_skill_miss',
                   'check_belief_avg_capital_reach', 'check_belief_avg_skill_reach',
                   'check_belief_avg_effort_reach', 'check_belief_avg_capital_miss',
                   'check_belief_avg_skill_miss', 'check_belief_avg_effort_miss', 'time_spent']

    @staticmethod
    def is_displayed(player: Player):
        return player.current_treatment == 'Low-Low' and player.current_task == 'Effort'\
               or player.current_treatment == 'Low-High' and player.current_task == 'Effort'\
               or player.round_firstHL == player.subsession.round_number

    @staticmethod
    def js_vars(player: Player):
        return dict(capital_mean=C.CAPITAL_MEAN, skill_lb=C.SKILL_LB,
                    skill_ub_low=C.SKILL_UB_LOW, skill_ub_high=C.SKILL_UB_HIGH,
                    capital_lb_high=C.CAPITAL_LB_HIGH, capital_ub_high=C.CAPITAL_UB_HIGH)

    @staticmethod
    def error_message(player: Player, value):
        if player.current_treatment == 'High-Low':
            if value["check_belief_avg_capital_reach"] == None or value["check_belief_avg_capital_miss"] == None:
                return 'Please answer each question.'
            else:
                if value["check_belief_avg_skill_reach"] == None or value["check_belief_avg_effort_reach"] == None \
                        or value["check_belief_avg_skill_miss"] == None or value["check_belief_avg_effort_miss"] == None:
                    return 'Please answer each question.'
        if player.current_treatment == 'Low-Low' or player.current_treatment == "Low-High":
            if value["check_belief_avg_skill_reach"] == None or value["check_belief_avg_effort_reach"] == None \
                    or value["check_belief_avg_skill_miss"] == None or value["check_belief_avg_effort_miss"] == None:
                return 'Please answer each question.'

class Feedback(Page):

    form_model = 'player'
    form_fields = ['time_spent_feedback']

    @staticmethod
    def is_displayed(player: Player):
        return player.current_task == 'Effort'

    @staticmethod
    def js_vars(player: Player):
        return dict(capital_mean=C.CAPITAL_MEAN, skill_lb=C.SKILL_LB,
                    skill_ub_low=C.SKILL_UB_LOW, skill_ub_high=C.SKILL_UB_HIGH,
                    capital_lb_high=C.CAPITAL_LB_HIGH, capital_ub_high=C.CAPITAL_UB_HIGH)

class Redistribute(Page):
    form_model = 'player'
    form_fields = ['give_lucky', 'send_unlucky', 'give_merit', 'send_lazy',
                   'check_send_unlucky', 'check_send_lazy']

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS_STG1 + 1

    @staticmethod
    def js_vars(player: Player):
        return dict(bonus=C.BONUS)

    @staticmethod
    def error_message(player: Player, value):
        if value["check_send_unlucky"] == None or value["check_send_lazy"] == None:
            return 'Please make a decision for each choice.'

    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        player.give_lucky = C.BONUS-player.send_unlucky
        player.give_merit = C.BONUS-player.send_lazy

class WaitForNextStage(WaitPage):
    wait_for_all_groups = True

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS_STG1

    title_text = "End of Stage 1"
    body_text = "Congratulations, you have finished the first stage of the experiment. " \
                "You may now silently use your phone while other participants finish this stage. " \
                "The experiment will continue as soon as everyone is ready."

    @staticmethod
    def after_all_players_arrive(subsession: Subsession):
        players = subsession.get_players()
        for player in subsession.get_players():
            player.num_reach_LL_allplayers = sum([p.num_reach_LL_allrounds for p in players])
            player.num_miss_LL_allplayers = sum([p.num_miss_LL_allrounds for p in players])
            player.num_reach_LH_allplayers = sum([p.num_reach_LH_allrounds for p in players])
            player.num_miss_LH_allplayers = sum([p.num_miss_LH_allrounds for p in players])
            player.num_reach_HL_allplayers = sum([p.num_reach_HL_allrounds for p in players])
            player.num_miss_HL_allplayers = sum([p.num_miss_HL_allrounds for p in players])

            if player.num_reach_LH_allplayers != 0:
                player.avg_effort_reach_LH_allplayers = sum([p.total_effort_reach_LH_allrounds for p in players]) / player.num_reach_LH_allplayers
                player.avg_skill_reach_LH_allplayers = sum([p.total_skill_reach_LH_allrounds for p in players]) / player.num_reach_LH_allplayers
                player.avg_capital_reach_LH_allplayers = sum([p.total_capital_reach_LH_allrounds for p in players]) / player.num_reach_LH_allplayers
            if player.num_miss_LH_allplayers != 0:
                player.avg_effort_miss_LH_allplayers = sum([p.total_effort_miss_LH_allrounds for p in players]) / player.num_miss_LH_allplayers
                player.avg_skill_miss_LH_allplayers = sum([p.total_skill_miss_LH_allrounds for p in players]) / player.num_miss_LH_allplayers
                player.avg_capital_miss_LH_allplayers = sum([p.total_capital_miss_LH_allrounds for p in players]) / player.num_miss_LH_allplayers
            if player.num_reach_LL_allplayers != 0:
                player.avg_effort_reach_LL_allplayers = sum([p.total_effort_reach_LL_allrounds for p in players]) / player.num_reach_LL_allplayers
                player.avg_skill_reach_LL_allplayers = sum([p.total_skill_reach_LL_allrounds for p in players]) / player.num_reach_LL_allplayers
                player.avg_capital_reach_LL_allplayers = sum([p.total_capital_reach_LL_allrounds for p in players]) / player.num_reach_LL_allplayers
            if player.num_miss_LL_allplayers != 0:
                player.avg_effort_miss_LL_allplayers = sum([p.total_effort_miss_LL_allrounds for p in players]) / player.num_miss_LL_allplayers
                player.avg_skill_miss_LL_allplayers = sum([p.total_skill_miss_LL_allrounds for p in players]) / player.num_miss_LL_allplayers
                player.avg_capital_miss_LL_allplayers = sum([p.total_capital_miss_LL_allrounds for p in players]) / player.num_miss_LL_allplayers
            if player.num_reach_HL_allplayers != 0:
                player.avg_effort_reach_HL_allplayers = sum([p.total_effort_reach_HL_allrounds for p in players]) /player.num_reach_HL_allplayers
                player.avg_skill_reach_HL_allplayers = sum([p.total_skill_reach_HL_allrounds for p in players]) / player.num_reach_HL_allplayers
                player.avg_capital_reach_HL_allplayers = sum([p.total_capital_reach_HL_allrounds for p in players]) / player.num_reach_HL_allplayers
            if player.num_miss_HL_allplayers != 0:
                player.avg_effort_miss_HL_allplayers = sum([p.total_effort_miss_HL_allrounds for p in players]) /player.num_miss_HL_allplayers
                player.avg_skill_miss_HL_allplayers = sum([p.total_skill_miss_HL_allrounds for p in players]) / player.num_miss_HL_allplayers
                player.avg_capital_miss_HL_allplayers = sum([p.total_capital_miss_HL_allrounds for p in players]) / player.num_miss_HL_allplayers

            player.earnings_capital_reach_HL = max(100 - 0.06*pow(player.in_round(player.round_firstHL).belief_avg_capital_reach - player.avg_capital_reach_HL_allplayers, 2), 0)
            player.earnings_capital_miss_HL = max(100 - 0.06*pow(player.in_round(player.round_firstHL).belief_avg_capital_miss - player.avg_capital_miss_HL_allplayers, 2), 0)
            player.earnings_skill_reach_HL = max(100 - 0.06*pow(player.in_round(player.round_firstHL).belief_avg_skill_reach - player.avg_skill_reach_HL_allplayers, 2), 0)
            player.earnings_skill_miss_HL = max(100 - 0.06*pow(player.in_round(player.round_firstHL).belief_avg_skill_miss - player.avg_skill_miss_HL_allplayers, 2), 0)
            player.earnings_effort_reach_HL = max(100 - 0.06*pow(player.in_round(player.round_firstHL).belief_avg_effort_reach - player.avg_effort_reach_HL_allplayers, 2), 0)
            player.earnings_effort_miss_HL = max(100 - 0.06*pow(player.in_round(player.round_firstHL).belief_avg_effort_miss - player.avg_effort_miss_HL_allplayers, 2), 0)
            player.earnings_skill_reach_LL = max(100 - 0.06*pow(player.in_round(player.round_firstLL).belief_avg_skill_reach - player.avg_skill_reach_LL_allplayers, 2), 0)
            player.earnings_skill_miss_LL = max(100 - 0.06*pow(player.in_round(player.round_firstLL).belief_avg_skill_miss - player.avg_skill_miss_LL_allplayers, 2), 0)
            player.earnings_effort_reach_LL = max(100 - 0.06*pow(player.in_round(player.round_firstLL).belief_avg_effort_reach - player.avg_effort_reach_LL_allplayers, 2), 0)
            player.earnings_effort_miss_LL = max(100 - 0.06*pow(player.in_round(player.round_firstLL).belief_avg_effort_miss - player.avg_effort_miss_LL_allplayers, 2), 0)
            player.earnings_skill_reach_LH = max(100 - 0.06*pow(player.in_round(player.round_firstLH).belief_avg_skill_reach - player.avg_skill_reach_LH_allplayers, 2), 0)
            player.earnings_skill_miss_LH = max(100 - 0.06*pow(player.in_round(player.round_firstLH).belief_avg_skill_miss - player.avg_skill_miss_LH_allplayers, 2), 0)
            player.earnings_effort_reach_LH = max(100 - 0.06*pow(player.in_round(player.round_firstLH).belief_avg_effort_reach - player.avg_effort_reach_LH_allplayers, 2), 0)
            player.earnings_effort_miss_LH = max(100 - 0.06*pow(player.in_round(player.round_firstLH).belief_avg_effort_miss - player.avg_effort_miss_LH_allplayers, 2), 0)
            player.belief_earnings = (player.earnings_capital_reach_HL + player.earnings_capital_miss_HL +
            player.earnings_skill_reach_HL + player.earnings_skill_miss_HL + player.earnings_effort_reach_HL +
            player.earnings_effort_miss_HL + player.earnings_skill_reach_LL + player.earnings_skill_miss_LL +
            player.earnings_effort_reach_LL + player.earnings_effort_miss_LL + player.earnings_skill_reach_LH +
            player.earnings_skill_miss_LH + player.earnings_effort_reach_LH + player.earnings_effort_miss_LH)
            player.payoff = player.slider_earnings + player.belief_earnings

        successful_HL = []
        not_successful_HL = []
        successful_LL = []
        not_successful_LL = []
        successful_LH = []
        not_successful_LH = []
        for player in subsession.get_players():
            participant = player.participant
            for i in range(1, len(C.TREATMENT)):
                if player.in_round(i).current_treatment == 'High-Low':
                    if player.in_round(i).target_is_reached == 1:
                        successful_HL.append([player.id_in_group, i, player.in_round(i).capital_reach_HL, player.in_round(i).skill_reach_HL, player.in_round(i).effort_reach_HL])
                    else:
                        not_successful_HL.append([player.id_in_group, i, player.in_round(i).capital_miss_HL, player.in_round(i).skill_miss_HL,
                                             player.in_round(i).effort_miss_HL])
                if player.in_round(i).current_treatment == 'Low-Low':
                    if player.in_round(i).target_is_reached == 1:
                        successful_LL.append([player.id_in_group, i, player.in_round(i).skill_reach_LL, player.in_round(i).effort_reach_LL])
                    else:
                        not_successful_LL.append([player.id_in_group, i, player.in_round(i).skill_miss_LL, player.in_round(i).effort_miss_LL])
                if player.in_round(i).current_treatment == 'Low-High':
                    if player.in_round(i).target_is_reached == 1:
                        successful_LH.append([player.id_in_group, i, player.in_round(i).skill_reach_LH, player.in_round(i).effort_reach_LH])
                    else:
                        not_successful_LH.append([player.id_in_group, i, player.in_round(i).skill_miss_LH, player.in_round(i).effort_miss_LH])

            if player.current_treatment == 'High-Low':
                if player.target_is_reached == 1:
                    successful_HL.append(
                        [player.id_in_group, player.round_number, player.capital_reach_HL, player.skill_reach_HL,
                         player.effort_reach_HL])
                else:
                    not_successful_HL.append(
                        [player.id_in_group, player.round_number, player.capital_miss_HL, player.skill_miss_HL,
                         player.effort_miss_HL])
            if player.current_treatment == 'Low-Low':
                if player.target_is_reached == 1:
                    successful_LL.append(
                        [player.id_in_group, player.round_number, player.skill_reach_LL, player.effort_reach_LL])
                else:
                    not_successful_LL.append(
                        [player.id_in_group, player.round_number, player.skill_miss_LL, player.effort_miss_LL])
            if player.current_treatment == 'Low-High':
                if player.target_is_reached == 1:
                    successful_LH.append(
                        [player.id_in_group, player.round_number, player.skill_reach_LH, player.effort_reach_LH])
                else:
                    not_successful_LH.append(
                        [player.id_in_group, player.round_number, player.skill_miss_LH, player.effort_miss_LH])
            participant.successful_HL = successful_HL
            participant.not_successful_HL = not_successful_HL
            participant.successful_LL = successful_LL
            participant.not_successful_LL = not_successful_LL
            participant.successful_LH = successful_LH
            participant.not_successful_LH = not_successful_LH
            print('HL winner list is:', participant.successful_HL)
            print('HL loser list is:', participant.not_successful_HL)
            print('LL winner list is:', participant.successful_LL)
            print('LL loser list is:', participant.not_successful_LL)
            print('LH winner list is:', participant.successful_LH)
            print('LH loser list is:', participant.not_successful_LH)

class Survey(Page):

    form_model = Player
    form_fields = ['politics_GSS', 'escape_poverty_WVS', 'inequality_Stan',
                   'luck_vs_effort', 'inequality_perception', 'rich_merit',
                   'poor_lazy', 'inequality_useful', 'social_mobility2', 'social_class']

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS

class Belief_stage2(Page):
    form_model = Player
    form_fields = ['give_winner', 'send_loser', 'check_send_loser']

    @staticmethod
    def is_displayed(player: Player):
        return player.current_task == 'Redistribute' and player.info == 0

    @staticmethod
    def js_vars(player: Player):
        return dict(bonus=C.BONUS)

    @staticmethod
    def vars_for_template(player: Player):
        if player.current_treatment == 'Low-Low':
            effort_reach = player.belief_avg_effort_reach = player.in_round(player.round_firstLL).belief_avg_effort_reach
            effort_miss = player.belief_avg_effort_miss = player.in_round(player.round_firstLL).belief_avg_effort_miss
            skill_reach = player.belief_avg_skill_reach = player.in_round(player.round_firstLL).belief_avg_skill_reach
            skill_miss = player.belief_avg_skill_miss = player.in_round(player.round_firstLL).belief_avg_skill_miss
            capital_reach = C.CAPITAL_MEAN
            capital_miss = C.CAPITAL_MEAN
        if player.current_treatment == 'Low-High':
            effort_reach = player.belief_avg_effort_reach = player.in_round(player.round_firstLH).belief_avg_effort_reach
            effort_miss = player.belief_avg_effort_miss = player.in_round(player.round_firstLH).belief_avg_effort_miss
            skill_reach = player.belief_avg_skill_reach = player.in_round(player.round_firstLH).belief_avg_skill_reach
            skill_miss = player.belief_avg_skill_miss = player.in_round(player.round_firstLH).belief_avg_skill_miss
            capital_reach = C.CAPITAL_MEAN
            capital_miss = C.CAPITAL_MEAN
        if player.current_treatment == 'High-Low':
            effort_reach = player.belief_avg_effort_reach = player.in_round(player.round_firstHL).belief_avg_effort_reach
            effort_miss = player.belief_avg_effort_miss = player.in_round(player.round_firstHL).belief_avg_effort_miss
            skill_reach = player.belief_avg_skill_reach = player.in_round(player.round_firstHL).belief_avg_skill_reach
            skill_miss = player.belief_avg_skill_miss = player.in_round(player.round_firstHL).belief_avg_skill_miss
            capital_reach = player.belief_avg_capital_reach = player.in_round(player.round_firstHL).belief_avg_capital_reach
            capital_miss = player.belief_avg_capital_miss = player.in_round(player.round_firstHL).belief_avg_capital_miss

        return dict(belief_effort_reach=effort_reach, belief_effort_miss=effort_miss,
                    belief_skill_miss=skill_miss, belief_skill_reach=skill_reach,
                    belief_capital_reach=capital_reach,belief_capital_miss=capital_miss
                    )

    @staticmethod
    def error_message(player: Player, value):
        if value["check_send_loser"] == None:
            return 'Please make a decision.'

    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        player.give_winner = C.BONUS-player.send_loser

class Results(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS

    @staticmethod
    def vars_for_template(player: Player):
        slider_earnings = player.in_round(9).slider_earnings
        belief_earnings = round(player.in_round(5).belief_earnings + player.in_round(10).belief_earnings, 0)
        redistribution_earnings = player.in_round(C.NUM_ROUNDS).points_from_redistribution
        payoff = slider_earnings + belief_earnings + redistribution_earnings
        dollar = (payoff*0.01)
        total_payoff = player.total_payoff = dollar + 5 #show-up fee

        return dict(slider_earnings=slider_earnings, belief_earnings=belief_earnings,
                    redistribution_earnings=redistribution_earnings,
                    payoff=payoff, dollar=dollar, total_payoff=total_payoff
                    )

class Wait_for_instructions(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1 or player.round_number == C.NUM_ROUNDS_STG1 + 1 or player.round_number == C.NUM_ROUNDS - 1

class Wait_for_instructions2(Page): #wait for instructions before redistribution in stage 3
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS

class Instructions_task(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1

class Instructions_earnings(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1

class Instructions_stage2(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS_STG1 + 1

#STAGE 3 PAGES
class Wait_endstage2(WaitPage):
    @staticmethod
    def is_displayed(player: Player): #end of stage 2 only
        return player.round_number == C.NUM_ROUNDS_STG1 + C.NUM_ROUNDS_STG2

    title_text = "End of Stage 2"
    body_text = "Stage 3 will start as soon as all participants are ready."

class Instructions_stage3(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS - 1

class Wait_stage3(WaitPage):
    wait_for_all_groups = True

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS - 1

    title_text = "Waiting for other participants to finish."
    body_text = "You may now silently use your phone while other participants finish."

    @staticmethod
    def after_all_players_arrive(subsession: Subsession):
        import random
        successful_HL_stage3 = []
        not_successful_HL_stage3 = []
        players = subsession.get_players()
        # create two lists: one with player who reach the target and one with list of players who fail
        for player in subsession.get_players():
            player.num_reach_stage3 = sum([p.target_is_reached for p in players])
            player.num_miss_stage3 = player.num_participants - player.num_reach_stage3
            if player.target_is_reached == 1:
                successful_HL_stage3.append(
                    [player.id_in_group, player.round_number, player.capital_reach_HL, player.skill_reach_HL,
                     player.effort_reach_HL])
            else:
                not_successful_HL_stage3.append(
                    [player.id_in_group, player.round_number, player.capital_miss_HL, player.skill_miss_HL,
                     player.effort_miss_HL])
        print('successful_HL_stage3:', successful_HL_stage3)
        print('not_successful_HL_stage3:', not_successful_HL_stage3)
        print('length successful_HL_stage3:', len(successful_HL_stage3))
        print('length not successful_HL_stage3:', len(not_successful_HL_stage3))

        pairs = []
        size_min = min(len(successful_HL_stage3), len(not_successful_HL_stage3))
        size_max = max(len(successful_HL_stage3), len(not_successful_HL_stage3))
        difference = size_max - size_min
        print('size min:', size_min)
        print('size max:', size_max)
        print('difference', difference)
        i = 0
        j = 0
        while i < size_min: #one to one matching (Successful #1 matched with not_uccessful #1 etc.)
            pairs.append([successful_HL_stage3[i], not_successful_HL_stage3[i]])
            i += 1
            print('P', player.id_in_group, 'my pair for reach=miss is:', pairs)
        while j < difference+1: #then match the ones from the longer list with the first of the shorter list
            if len(successful_HL_stage3) > len(not_successful_HL_stage3):
                pairs.append([successful_HL_stage3[size_min - 1 + j], random.sample(not_successful_HL_stage3, 1)[0]])
                j += 1
                print('P', player.id_in_group, 'my pair if reach>miss is:', pairs)
            if len(successful_HL_stage3) < len(not_successful_HL_stage3):
                pairs.append([random.sample(successful_HL_stage3, 1)[0], not_successful_HL_stage3[size_min - 1 + j]])
                j += 1
                print('P', player.id_in_group, 'my pair if miss>reach:', pairs)

        # assign the lists to all participants
        successful_HL_stage3_mylist = []
        not_successful_HL_stage3_myslist = []
        mypair = []
        allpairs = []
        for player in subsession.get_players():
            participant = player.participant
            participant.successful_HL_stage3 = successful_HL_stage3
            participant.not_successful_HL_stage3 = not_successful_HL_stage3
            participant.pairs = pairs # list of all possible pairs to choose from
            print('P', player.id_in_group, 'list of common pair is:', pairs)
            print('length common pairs', len(pairs))
            # create list that only contains other players
            successful = participant.successful_HL_stage3_mylist = [el for el in successful_HL_stage3 if el[0] != player.id_in_group]
            not_successful = participant.not_successful_HL_stage3_mylist = [el for el in not_successful_HL_stage3 if el[0] != player.id_in_group]
            print('length successful is:', len(successful))
            print('length not_successful is:', len(not_successful))
            print('P', player.id_in_group, 'winner list in stage 3 is:', participant.successful_HL_stage3_mylist)
            print('P', player.id_in_group, 'loser list in stage 3 is:', participant.not_successful_HL_stage3_mylist)

            # create list of all eligible pair for player i (i.e. all pairs excluding himself)
            possible_pairs = participant.possible_pairs = [el for el in pairs if el[:][0][0] != player.id_in_group and el[:][1][0] != player.id_in_group]
            print('P', player.id_in_group, 'possible pairs', possible_pairs)
            print('length possible pair is:', len(possible_pairs))

            if len(possible_pairs) == 1: #if only one pair
                mypair = possible_pairs
            if len(possible_pairs) == 2:
                if (possible_pairs[0][0][0] == possible_pairs[1][0][0] or possible_pairs[0][1][0] == possible_pairs[1][1][0]):
                #if same player in both possible pairs, only pick one pair. Else pick both.
                    mypair = random.sample(possible_pairs, 1)
                else:
                    mypair = random.sample(possible_pairs, 2)
            if len(possible_pairs) > 2 and len(successful) != 1 and len(not_successful) != 1:
                mypair = random.sample(possible_pairs, 2)
                while mypair[0][0][0] == mypair[1][0][0] or mypair[0][1][0] == mypair[1][1][0]:
                    mypair = random.sample(possible_pairs, 2)
            # if there's only one winner or looser besides player i, just show one pair
            if len(possible_pairs) > 2 and len(successful) == 1:
                mypair = random.sample(possible_pairs, 1)
            if len(possible_pairs) > 2 and len(not_successful) == 1:
                mypair = random.sample(possible_pairs, 1)
            participant.mypair = mypair
            print('P', player.id_in_group, 'my selected pairs are:', mypair)
            allpairs.append(mypair)
        print('allpairs:', allpairs)

        for player in subsession.get_players():
            participant = player.participant
            participant.allpairs = allpairs

class Redistribute_stage3(Page):

    form_model = Player
    form_fields = ['give_winner_pair1', 'send_loser_pair1', 'give_winner_pair2', 'send_loser_pair2',
                   'check_send_loser_pair1', 'check_send_loser_pair2',
                   'belief_effort_reach_pair1', 'belief_effort_miss_pair1', 'belief_skill_reach_pair1',
                   'belief_skill_miss_pair1', 'belief_effort_reach_pair2', 'belief_effort_miss_pair2',
                   'belief_skill_reach_pair2', 'belief_skill_miss_pair2',
                   'check_belief_effort_reach_pair1', 'check_belief_effort_miss_pair1', 'check_belief_skill_reach_pair1',
                   'check_belief_skill_miss_pair1', 'check_belief_effort_reach_pair2', 'check_belief_effort_miss_pair2',
                   'check_belief_skill_reach_pair2', 'check_belief_skill_miss_pair2',
                   ]

    @staticmethod
    def is_displayed(player: Player):
        return player.current_task == 'Redistribute' and player.info == 1 \
               and player.in_round(9).num_reach_stage3 >= 2 and player.in_round(9).num_miss_stage3 >= 2

    @staticmethod
    def vars_for_template(player: Player):
        participant = player.participant
        successful = participant.successful_HL_stage3_mylist
        not_successful = participant.not_successful_HL_stage3_mylist
        mypair = participant.mypair
        print('My pair is:', mypair)
        pairs = participant.pairs
        allpairs = participant.allpairs
        possible_pairs = participant.possible_pairs
        size_mypair = participant.size_mypair = len(mypair) #number of pairs to determine if show one or two
        reach2 = []
        miss2 = []
        reach1 = player.capital_reach_pair1 = mypair[0][0][2] #starting line of player who reach in pair #1
        miss1 = player.capital_miss_pair1 = mypair[0][1][2] #starting line of player who miss in pair #1
        player.skill_reach_pair1 = mypair[0][0][3]  #skill of player who reach in pair #1
        player.skill_miss_pair1 = mypair[0][1][3]  #skill of player who miss in pair #1
        player.effort_reach_pair1 = mypair[0][0][4]  #effort of player who reach in pair #1
        player.effort_miss_pair1 = mypair[0][1][4]  #effort of player who miss in pair #1
        print('Reach1 is:', reach1)
        print('Miss1 is:', miss1)
        if len(mypair) > 1:
            reach2 = player.capital_reach_pair2 = mypair[1][0][2] #starting line of player who reach in pair #2
            miss2 = player.capital_miss_pair2 = mypair[1][1][2] #same for miss pair #2
            player.skill_reach_pair2 = mypair[1][0][3]  # skill of player who reach in pair #1
            player.skill_miss_pair2 = mypair[1][1][3]  # skill of player who miss in pair #1
            player.effort_reach_pair2 = mypair[1][0][4]  # effort of player who reach in pair #1
            player.effort_miss_pair2 = mypair[1][1][4]  # effort of player who miss in pair #1
            print('Reach2 is:', reach2)
            print('Miss2 is:', miss2)

        return dict(successful=successful, not_successful=not_successful, pairs=pairs, possible_pairs=possible_pairs,
                    my_pair=mypair, size_mypair=size_mypair, allpairs=allpairs,
                    reach1=reach1, miss1=miss1, reach2=reach2, miss2=miss2,
                    )

    @staticmethod
    def error_message(player: Player, value):
        p = player.participant
        if p.size_mypair >= 1 and value["check_send_loser_pair1"] == None:
            return 'Please move the slider to make a decision for pair #1.'
        if p.size_mypair >= 2 and value["check_send_loser_pair2"] == None:
            return 'Please move the slider to make a decision for pair #2.'
        if p.size_mypair >= 3 and value["check_send_loser_pair3"] == None:
            return 'Please move the slider to make a decision for pair #3.'
        if p.size_mypair >= 1 and (value["check_belief_effort_reach_pair1"] == None or value["check_belief_skill_reach_pair1"] == None \
                or value["check_belief_effort_miss_pair1"] == None or value["check_belief_skill_miss_pair1"] == None):
            return 'Please answer each question for pair #1.'
        if p.size_mypair >= 2 and (value["check_belief_effort_reach_pair2"] == None or value["check_belief_skill_reach_pair2"] == None \
                or value["check_belief_effort_miss_pair2"] == None or value["check_belief_skill_miss_pair2"] == None):
            return 'Please answer each question for pair #2.'

    @staticmethod
    def js_vars(player: Player):
        return dict(bonus=C.BONUS)

    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        participant = player.participant
        mypair = participant.mypair
        allpairs = participant.allpairs
        player.give_winner_pair1 = C.BONUS - player.send_loser_pair1
        player.give_winner_pair2 = C.BONUS - player.send_loser_pair2
        reach1_id = mypair[0][0][0]
        miss1_id = mypair[0][1][0]
        player.belief_earnings = (max(100 - 0.06*pow(player.belief_effort_reach_pair1 - mypair[0][0][4], 2), 0)
                + max(100 - 0.06*pow(player.belief_effort_miss_pair1 - mypair[0][1][4], 2), 0)
                + max(100 - 0.06*pow(player.belief_skill_reach_pair1 - mypair[0][0][3], 2), 0)
                + max(100 - 0.06*pow(player.belief_skill_miss_pair1 - mypair[0][1][3], 2), 0))
        if player.group.get_player_by_id(reach1_id).points_from_redistribution == 1:
            player.group.get_player_by_id(reach1_id).points_from_redistribution = player.give_winner_pair1
        if player.group.get_player_by_id(miss1_id).points_from_redistribution == 1:
            player.group.get_player_by_id(miss1_id).points_from_redistribution = player.send_loser_pair1
        if len(mypair) > 1:
            reach2_id = mypair[1][0][0]
            miss2_id = mypair[1][1][0]
            player.belief_earnings = (max(100 - 0.06 * pow(player.belief_effort_reach_pair1 - mypair[0][0][4], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_effort_miss_pair1 - mypair[0][1][4], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_skill_reach_pair1 - mypair[0][0][3], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_skill_miss_pair1 - mypair[0][1][3], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_effort_reach_pair2 - mypair[1][0][4], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_effort_miss_pair2 - mypair[1][1][4], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_skill_reach_pair2 - mypair[1][0][3], 2), 0)
                    + max(100 - 0.06 * pow(player.belief_skill_miss_pair2 - mypair[1][1][3], 2), 0))
            if player.group.get_player_by_id(reach2_id).points_from_redistribution == 1:
                player.group.get_player_by_id(reach2_id).points_from_redistribution = player.give_winner_pair2
            if player.group.get_player_by_id(miss2_id).points_from_redistribution == 1:
                player.group.get_player_by_id(miss2_id).points_from_redistribution = player.send_loser_pair2

        allids = [] #check that each player is at least once in one pair that's displayed.
        for i in range(0, len(allpairs)):
            for j in range(0, len(allpairs[i])):
                allids.append(allpairs[i][j][0][0])
                allids.append(allpairs[i][j][1][0])
        print('allids:', allids)
        if player.id_in_group not in allids: #if a player wasn't displayed, give him 50pts
            print('missing id!:participant', player.id_in_group)
            player.points_from_redistribution = 50
        else:
            print('my id is not missing')

class Wait_postredist(WaitPage):
    wait_for_all_groups = True

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS

    title_text = "Waiting for other participants to finish."
    body_text = "You may now silently use your phone while other participants finish."

class Comprehension(Page):
    form_model = Player
    form_fields = ['q1', 'q2', 'q3', 'q4', 'q5']

    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1

    @staticmethod
    def error_message(player: Player, value):
        if value['q1'] == 0:
            return "Your answer to question 1 is incorrect."
        if value['q2'] == 0:
            return "Your answer to question 2 is incorrect."
        if value['q3'] == 0:
            return "Your answer to question 3 is incorrect."
        if value['q4'] == 0:
            return "Your answer to question 4 is incorrect."
        if value['q5'] == 0:
            return "Your answer to question 5 is incorrect."


page_sequence = [Welcome, Wait_for_instructions, Instructions_task, Instructions_earnings, Comprehension, Instructions_stage2, Instructions_stage3, Rule,
                 Reveal_draws, Game, Feedback, Belief_reach, WaitForNextStage, Wait_stage3,
                 Redistribute, Belief_stage2, Wait_endstage2, Wait_for_instructions2, Redistribute_stage3, Wait_postredist, Survey, Results]
