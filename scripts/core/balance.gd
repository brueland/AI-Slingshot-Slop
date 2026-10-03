class_name Balance
extends RefCounted
## Every tuning number in the game. See docs/DESIGN.md section 3.

const GRAVITY: float = 15.0
const BASE_MAX_SPEED: float = 22.0
const MAX_PULL_PX: float = 120.0
const MIN_PULL_PX: float = 10.0
const BASE_LAUNCH_HEIGHT: float = 2.0
const BASE_DRAG: float = 0.002
const BASE_RESTITUTION: float = 0.45
const BOUNCE_FRICTION: float = 0.9
const MIN_BOUNCE_SPEED: float = 2.0
const SLIDE_FRICTION: float = 6.0
const STOP_SPEED: float = 0.1
const BOOST_SPEED: float = 12.0
## The rocket fires while the boost key is held: BOOST_THRUST m/s of push per second, and each rocket tank (upgrade
## level or Rocket perk) burns for BOOST_TANK_SECONDS per flight. A full tank adds BOOST_SPEED, like the old boost.
const BOOST_THRUST: float = 24.0
const BOOST_TANK_SECONDS: float = 0.5
const BASE_GUIDE_POINTS: int = 6
const BASE_STAR_VALUE: int = 10
const STAR_RADIUS: float = 1.5
const SPRING_SPEED: float = 14.0
const SPRING_PUSH: float = 4.0
const SPRING_HALF_WIDTH: float = 1.5
const MUD_FACTOR: float = 0.5
const MUD_WIDTH: float = 6.0
const COURSE_LENGTH: float = 2000.0
const GOAL_DISTANCE: float = 1000.0
const MAX_RUN_SECONDS: float = 120.0
const PIXELS_PER_METER: float = 16.0
const PROJECTILE_RADIUS: float = 0.75
## The alien is drawn this much bigger than PROJECTILE_RADIUS; star pickups use the drawn body.
const LOOK_SCALE: float = 1.5
## Roguelike landing zones sit in a dip: the floor between the zone's edges is DIP_DEPTH lower, with a DIP_SLOPE-wide
## slope outside each edge. The slopes are too steep to rest on, so a shot that stops on one rolls into the zone.
const DIP_DEPTH: float = 0.75
const DIP_SLOPE: float = 1.5
## A giant brick wall stands this far behind the slingshot (meters); the alien bounces off it.
const WALL_X: float = -120.0
